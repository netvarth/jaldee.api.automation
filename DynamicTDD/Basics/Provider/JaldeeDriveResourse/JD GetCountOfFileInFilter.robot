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
@{person_ahead}        0  1  2  3  4  5  6
${self}               0
@{service_duration}   5   20
${parallel}     1
${SERV}         CHECK 
${xlFile}       ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
${xlFile2}      ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
@{folderName}      privateFolder     publicFolder
@{ownerType}   Provider  ProviderConsumer 


***Test Cases***


JD-TC-GetCountOfFileInFilter-1
    [Documentation]  Filter  folderName -shared file
    
    clear_customer     ${PUSERNAME77}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${acc_id}=  get_acc_id  ${PUSERNAME77}
    Set Suite Variable    ${acc_id}
    ${id}=  get_id  ${PUSERNAME77}
    Set Suite Variable  ${id}
  
    ${msg}=   FakerLibrary.Word
    ${caption}=  Fakerlibrary.sentence
    ${caption1}=  Fakerlibrary.Sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
 
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}

    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${jpegfile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType}   order=0
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200

   
    ${caption1}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Suite Variable    ${fileType}

    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${pdffile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType}   order=0
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200


    ${caption2}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    
    ${fileType3}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType3}
    ${caption3}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    
    ${fileType1}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType1}

    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${jpegfile}    fileSize=0.0085     caption=${caption2}     fileType=${fileType3}   order=0
    ${list2}=  Create Dictionary         owner=${id}   fileName=${pngfile}    fileSize=0.0085     caption=${caption3}     fileType=${fileType1}   order=0
   
    ${list}=   Create List     ${list1}    ${list2}
    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200

    ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}    ${id}
    Log  ${resp.content}
    ${FLength}=  Get Length  ${resp.json()}   
    Set Suite Variable    ${FLength}
   
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME7}
    clear_Consumermsg  ${CUSERNAME7}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME7}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pdffile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpegfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${giffile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    ${resp}=   Get Count of Files in a filter      account-eq=${acc_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    7
    

JD-TC-GetCountOfFileInFilter-2

    [Documentation]  get count- Filter  owner type

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Count of Files in a filter     owner-eq=${id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    ${FLength}
  
JD-TC-GetCountOfFileInFilter-3

    [Documentation]  get count- Filter  contextType

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Count of Files in a filter     contextType-eq=jaldeeDrive
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    ${FLength}

JD-TC-GetCountOfFileInFilter-4

    [Documentation]   get count Filter  ownerType

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Count of Files in a filter     ownerType-eq=ProviderConsumer
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    3

JD-TC-GetCountOfFileInFilter-5

    [Documentation]  Filter   contextType-eq=communication

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Count of Files in a filter    contextType-eq=communication
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    3

JD-TC-GetCountOfFileInFilter-6

     [Documentation]  Filter  folderName -shared file

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

  
    
    ${resp}=   Get Count of Files in a filter     fileType-eq=jpeg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    1

JD-TC-GetCountOfFileInFilter-7

     [Documentation]    get count with Filter   pdf file

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Count of Files in a filter    fileType-eq=pdf
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    1
    
JD-TC-GetCountOfFileInFilter-8

     [Documentation]    get count Filter  gif file

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


        
    ${resp}=   Get Count of Files in a filter      fileType-eq=gif
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    1

JD-TC-GetCountOfFileInFilter-9

     [Documentation]   get count Filter  sharedType

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Count of Files in a filter   sharedType-eq=secureShare
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    ${FLength}

JD-TC-GetCountOfFileInFilter-10

    [Documentation]   get count Filter  ownerType-Provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Count of Files in a filter     ownerType-eq=Provider
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    ${FLength}

JD-TC-GetCountOfFileInFilter-11

    [Documentation]    get jpg file from jaldeedrive by user
    
    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME15} 
    Set Suite variable     ${pid}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

  
    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${HLMUSERNAME15} 
    clear_appt_schedule   ${HLMUSERNAME15}
    
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


    clear_Consumermsg  ${CUSERNAME2}
    clear_Providermsg  ${PUSERPH0}

    ${resp}=  Consumer Login  ${CUSERNAME2}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid2}=  get_id  ${CUSERNAME2}
    
    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithProvider   ${cookie}   ${p_id}  ${u_id}   ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${u_id} 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get User communications   ${u_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid2}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id} 

    ${resp}=   Get Count of Files in a filter    fileType-eq=jpg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    1

JD-TC-GetCountOfFileInFilter-12

    [Documentation]    upload file to uesr and get count by branch login
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption2}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${docfile}
    Log  ${resp}
    
    ${fileType2}=  Get From Dictionary       ${resp}    ${docfile}
    Set Suite Variable    ${fileType2}


    ${list1}=  Create Dictionary         owner=${u_id}   fileName=${docfile}    fileSize=0.076    caption=${caption2}     fileType=${fileType2}   order=16
   # ${list2}=  Create Dictionary         owner=${id}   fileName=${pngfile}    fileSize=0.00176    caption=${caption1}     fileType=${fileType1}   order=1
  
    ${list}=   Create List     ${list1}   


    ${resp}=    Upload To Private Folder      privateFolder    ${u_id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME15} 
    Set Suite variable     ${pid}

    ${resp}=   Get Count of Files in a filter    owner-eq=${u_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    1

JD-TC-GetCountOfFileInFilter-13

    [Documentation]    upload file to  branch and get count by  user login
    
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME15} 
    Set Suite variable     ${pid}
    ${id1}=  get_id   ${HLMUSERNAME15}
    Set Suite Variable  ${id1}
  
    ${caption1}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${txtfile}
    Log  ${resp}
    
    ${fileType2}=  Get From Dictionary       ${resp}    ${txtfile}
    Set Suite Variable    ${fileType2}


    ${list1}=  Create Dictionary         owner=${id1}   fileName=${txtfile}    fileSize=0.076    caption=${caption1}     fileType=${fileType2}   order=3
   # ${list2}=  Create Dictionary         owner=${id}   fileName=${pngfile}    fileSize=0.00176    caption=${caption1}     fileType=${fileType1}   order=1
  
    ${list}=   Create List     ${list1}   


    ${resp}=    Upload To Private Folder      privateFolder    ${id1}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Count of Files in a filter    owner-eq=${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    1


 
  
JD-TC-GetCountOfFileInFilter-UH1

    [Documentation]    consumer login
      
    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Count of Files in a filter     ownerType-eq=Provider
    Log  ${resp.json()}
    Should Be Equal As Strings           ${resp.status_code}  401
    Should Be Equal As Strings           ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetCountOfFileInFilter-UH2

    [Documentation]    Withoutlogin
      
    ${resp}=   Get Count of Files in a filter     ownerType-eq=Provider
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}  419
    Should Be Equal As Strings          ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetCountOfFileInFilter-UH3

    [Documentation]    empty filter
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=   Get Count of Files in a filter     fileType-eq=${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}  200
    Should Be Equal As Strings                 ${resp.json()}    0
  
   
JD-TC-GetCountOfFileInFilter-UH4

    [Documentation]    invalid  filter
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=   Get Count of Files in a filter    fileType-eq=00
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}  200
    Should Be Equal As Strings                 ${resp.json()}    0
  
   
JD-TC-GetCountOfFileInFilter-UH5

     [Documentation]    another provider login filter
      
   
    ${resp}=  Encrypted Provider Login            ${PUSERNAME1}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get Count of Files in a filter     ownerType-eq=Provider
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}  200
    Should Be Equal As Strings                 ${resp.json()}    0
  
   