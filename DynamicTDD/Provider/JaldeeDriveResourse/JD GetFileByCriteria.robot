***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Jaldee Drive
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

Library           /ebs/TDD/excelfuncs.py



*** Variables ***
@{countryCode}       91  +91  48 
${CUSERPH}           ${CUSERNAME}
${jpgfile}           /ebs/TDD/uploadimage.jpg
${pngfile}           /ebs/TDD/upload.png
${pdffile}           /ebs/TDD/sample.pdf
${SERVICE1}          Consultation 
${SERVICE2}          Scanning
${SERVICE3}          Scannings111
${SERVICE12}         numbers
${SERVICE23}         okperf
${SERVICE32}         thanku
@{service_duration}  10  20  30   40   50
${giffile}           /ebs/TDD/sample.gif
${jpegfile}          /ebs/TDD/large.jpeg
${bmpfile}           /ebs/TDD/first.bmp
${shfile}            /ebs/TDD/example.sh
${docfile}           /ebs/TDD/docsample.doc
${txtfile}           /ebs/TDD/textsample.txt
${digits}            0123456789
@{EMPTY_List} 
@{person_ahead}      0  1  2  3  4  5  6
${self}              0
@{service_duration}  5   20
${parallel}          1
${SERV1}              CHECK 
${SERV2}              CHECK12 
${SERV3}              CHECK33313
${xlFile}            ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
#${xlFile2}           ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
#@{folderName}        privateFolder     publicFolder
#${xlFile}            ${EXECDIR}/TDD/ServiceoptionsDonation.xlsx   # DataSheet
#${xlFile}             ${EXECDIR}/TDD/sampleQnrWOAV.xlsx    # DataSheet


***Test Cases***

JD-TC-GetFileByCriteria-1
	[Documentation]    Upload files

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${acc_id}=  get_acc_id  ${PUSERNAME66}
    Set Suite Variable    ${acc_id}
    ${id}=  get_id  ${PUSERNAME66}
    Set Suite Variable  ${id}
   

    clear_customer      ${PUSERNAME66} 

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
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME6} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid6}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid6}  ${resp.json()[0]['id']}
    END

 

    ${msg}=   FakerLibrary.Word
    ${caption}=  Fakerlibrary.sentence

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

    ${caption4}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${giffile}
    Log  ${resp}
    
    ${fileType6}=  Get From Dictionary       ${resp}    ${giffile}
    Set Suite Variable    ${fileType6}

    ${caption7}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    
    ${fileType7}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Suite Variable    ${fileType7}
    ${list7}=  Create Dictionary         owner=${id}   fileName=${pdffile}    fileSize=0.0085     caption=${caption7}     fileType=${fileType7}   order=7
  
    ${list1}=  Create Dictionary         owner=${id}   fileName=${giffile}    fileSize=0.0085     caption=${caption4}     fileType=${fileType6}   order=6
    ${list}=   Create List     ${list1}  ${list7}

    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 
    ${caption8}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    
    ${fileType8}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType8}

    ${caption9}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    
    ${fileType9}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType9}
   
    ${list7}=  Create Dictionary         owner=${id}   fileName=${jpgfile}    fileSize=0.0085     caption=${caption8}     fileType=${fileType8}   order=8
    ${list4}=  Create Dictionary         owner=${id}   fileName=${pngfile}    fileSize=0.0085     caption=${caption9}     fileType=${fileType9}   order=9
  
    ${list}=   Create List    ${list4}   ${list7}

    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 

    ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}    ${id}
    Log  ${resp.content}
  
   
    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME6}
    clear_Consumermsg  ${CUSERNAME6}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME6}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pdffile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    


JD-TC-GetFileByCriteria-2

    [Documentation]     get private files from jaldee drive

    ${resp}=  Encrypted Provider Login            ${PUSERNAME66}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200
    ${acc_id1}=  get_acc_id  ${PUSERNAME66}
    Set Suite Variable     ${acc_id1}
    ${id1}=  get_id  ${PUSERNAME66}
    Set Suite Variable  ${id1}
   

    ${resp}=   Get by Criteria          folderName-eq=private
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                             200
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['owner']}            ${id1}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['account']}                    ${acc_id1}

JD-TC-GetFileByCriteria-3

    [Documentation]     get shared files from jaldee drive

    ${resp}=  Encrypted Provider Login            ${PUSERNAME66}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get by Criteria          folderName-eq=shared
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                             200
    Should Be Equal As Strings          ${resp.json()['${cid6}']['files'][0]['context']}                    ${context[0]}
    Should Be Equal As Strings          ${resp.json()['${cid6}']['files'][0]['account']}                    ${acc_id}


JD-TC-GetFileByCriteria-4

    [Documentation]     get  files from jaldee drive - filter owner 

    ${resp}=  Encrypted Provider Login            ${PUSERNAME66}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get by Criteria          owner-eq=${id}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                         200
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['context']}                    ${context[4]}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['owner']}                      ${id}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['account']}                    ${acc_id}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][1]['context']}                    ${context[4]}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][1]['owner']}                      ${id}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][1]['account']}                    ${acc_id}
   


JD-TC-GetFileByCriteria-5

    [Documentation]     get  files from jaldee drive - filter  accound id

    ${resp}=  Encrypted Provider Login            ${PUSERNAME66}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get by Criteria          account-eq=${acc_id}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['account']}                    ${acc_id}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][1]['owner']}                      ${id}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][1]['account']}                    ${acc_id}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][2]['owner']}                      ${id}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][2]['account']}                    ${acc_id}
    
  
JD-TC-GetFileByCriteria-6

    [Documentation]     get  files from jaldee drive - filter contexttype-jaldeedrive

    ${resp}=  Encrypted Provider Login            ${PUSERNAME66}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get by Criteria          contextType-eq=jaldeeDrive
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['context']}                    ${context[4]}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['owner']}                      ${id}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['account']}                    ${acc_id}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['sharedType']}                 ${sharedType[0]} 
    
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][1]['context']}                    ${context[4]}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][1]['owner']}                      ${id}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][1]['account']}                    ${acc_id}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][1]['sharedType']}                 ${sharedType[0]} 
   
JD-TC-GetFileByCriteria-7

    [Documentation]     get  files from jaldee drive - filter ownertype- providerConsumer

    ${resp}=  Encrypted Provider Login            ${PUSERNAME66}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get by Criteria           ownerType-eq=ProviderConsumer
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings          ${resp.json()['${cid6}']['files'][0]['context']}                   ${context[0]}
    Should Be Equal As Strings          ${resp.json()['${cid6}']['files'][0]['account']}                   ${acc_id}
    Should Be Equal As Strings          ${resp.json()['${cid6}']['files'][0]['sharedType']}                ${sharedType[1]} 
    Should Be Equal As Strings          ${resp.json()['${cid6}']['files'][0]['fileType']}                  pdf
    Should Be Equal As Strings          ${resp.json()['${cid6}']['files'][0]['fileSize']}                  0.003
   
JD-TC-GetFileByCriteria-8

    [Documentation]     get  files from jaldee drive - filter  context: communication

    ${resp}=  Encrypted Provider Login            ${PUSERNAME66}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get by Criteria          contextType-eq=communication
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings          ${resp.json()['${cid6}']['files'][0]['context']}                    ${context[0]}
    #Should Be Equal As Strings          ${resp.json()[0]['owner']}                      ${id}
    Should Be Equal As Strings          ${resp.json()['${cid6}']['files'][0]['account']}                    ${acc_id}
    Should Be Equal As Strings          ${resp.json()['${cid6}']['files'][0]['sharedType']}                 ${sharedType[1]} 
    Should Be Equal As Strings          ${resp.json()['${cid6}']['files'][0]['fileType']}                   pdf
    Should Be Equal As Strings          ${resp.json()['${cid6}']['files'][0]['fileSize']}                   0.003
   

    

JD-TC-GetFileByCriteria-9

    [Documentation]     get  files from jaldee drive - filterfiletype: pdf

      
    ${resp}=  Encrypted Provider Login            ${PUSERNAME66}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get by Criteria          fileType-eq=pdf
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings         ${resp.json()['${cid6}']['files'][0]['account']}                   ${acc_id}
    Should Be Equal As Strings         ${resp.json()['${cid6}']['files'][0]['fileType']}                  pdf
    Should Be Equal As Strings         ${resp.json()['${cid6}']['files'][0]['fileName']}                  /ebs/TDD/sample
   



JD-TC-GetFileByCriteria-10

    [Documentation]     get  files from jaldee drive - filetype: png

      
    ${resp}=  Encrypted Provider Login            ${PUSERNAME66}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get by Criteria          sharedType-eq=secureShare
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['account']}                   ${acc_id}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['ownerType']}                 ${ownerType[0]}
    Should Be Equal As Strings          ${resp.json()['${id1}']['files'][0]['owner']}                     ${id}
 



JD-TC-GetFileByCriteria-11

	[Documentation]   user get  - filetype: jpg

    ${resp}=  Encrypted Provider Login  ${MUSERNAME7}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${MUSERNAME7} 
    Set Suite variable     ${pid}
    ${id2}=  get_id  ${MUSERNAME7}
    Set Suite Variable  ${id2}
   

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${MUSERNAME7} 
    clear_appt_schedule   ${MUSERNAME7}
    
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
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME2} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid2}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid2}  ${resp.json()[0]['id']}
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
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable  ${city}     ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}    ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin}      ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    clear_service                   ${PUSERPH0}
    clear_appt_schedule             ${PUSERPH0}


    ${resp}=  Create User           ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH0}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${sub_domain_id}  ${resp.json()['subdomain']}
    Verify Response                 ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.${test_mail}    deptId=${dep_id} 
    #  city=${city}      state=${state}
    # Should Be Equal As Strings  ${resp.json()['city']}      ${city}    ignore_case=True
    # Should Be Equal As Strings  ${resp.json()['state']}      ${state}    ignore_case=True
   
    ${resp}=  SendProviderResetMail   ${PUSERPH0}
    Should Be Equal As Strings      ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERPH0}  ${PASSWORD}  2
    Should Be Equal As Strings      ${resp[0].status_code}  200
    Should Be Equal As Strings      ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login         ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${lid}     ${resp.json()[0]['id']}
    ${uid}=  get_id  ${PUSERPH0}
    Set Suite Variable  ${uid}
   


    clear_Consumermsg               ${CUSERNAME2}
    clear_Providermsg               ${PUSERPH0}

    ${resp}=  Consumer Login        ${CUSERNAME2}   ${PASSWORD}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${jcid2}=  get_id                ${CUSERNAME2}
    
    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithProvider   ${cookie}   ${pid}  ${uid}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    
    ${resp}=  Encrypted Provider Login         ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
 
   
    ${resp}=   Get by Criteria      account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}                     200
    Should Be Equal As Strings          ${resp.json()['${cid2}']['files'][0]['account']}                   ${pid}
    Should Be Equal As Strings          ${resp.json()['${cid2}']['files'][0]['ownerType']}                 ${ownerType[1]}
    Should Be Equal As Strings          ${resp.json()['${cid2}']['files'][0]['context']}                   ${context[0]}

JD-TC-GetFileByCriteria-12

	[Documentation]   user get  filter in upload file to jaldeedrive

    ${resp}=  Encrypted Provider Login         ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${caption4}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${giffile}
    Log  ${resp}
    
    ${fileType6}=  Get From Dictionary       ${resp}    ${giffile}
    Set Suite Variable    ${fileType6}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${giffile}    fileSize=0.0085     caption=${caption4}     fileType=${fileType6}   order=6
    ${list}=   Create List     ${list1}

    ${resp}=    Upload To Private Folder      privateFolder    ${uid}    ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 
    ${resp}=   Get by Criteria         owner-eq=${uid}
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                                    200
    Should Be Equal As Strings          ${resp.json()['${uid}']['files'][0]['account']}                   ${pid}
    Should Be Equal As Strings          ${resp.json()['${uid}']['files'][0]['ownerType']}                 ${ownerType[0]} 
    Should Be Equal As Strings          ${resp.json()['${uid}']['files'][0]['context']}                   ${context[4]}   
    Should Be Equal As Strings          ${resp.json()['${uid}']['files'][0]['owner']}                     ${u_id}  

JD-TC-GetFileByCriteria-13

    [Documentation]  UploadTaskAttachment using Task Id.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME55}
    Set Test Variable  ${p_id}
    ${id}=  get_id  ${PUSERNAME55}
    Set Suite Variable  ${id}
   

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
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id1}
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
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Contain     "${resp.json()}"    jpg
    Should Contain     "${resp.json()}"     pdf
    
    ${resp}=   Get by Criteria         account-eq=${p_id}
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                                    200
    Should Be Equal As Strings         ${resp.json()['${id}']['files'][0]['account']}                   ${pid}
    Should Be Equal As Strings           ${resp.json()['${id}']['files'][0]['ownerType']}                 ${ownerType[0]}
    Should Be Equal As Strings           ${resp.json()['${id}']['files'][0]['context']}                   ${context[2]}
    

JD-TC-GetFileByCriteria-14
    [Documentation]   Upload prescription image  for a waitlist(Walk-in).
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+7861345
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id}  ${decrypted_data['id']}
    Set Suite Variable  ${userName}  ${decrypted_data['userName']}
    # Set Suite Variable    ${id}    ${resp.json()['id']} 
    # Set Suite Variable    ${userName}    ${resp.json()['userName']}         
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}

    ${pid}=  get_acc_id  ${PUSERNAME_C}
    Set Suite Variable  ${pid}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566187
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566187
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    # ${ph3}=  Evaluate  ${PUSERNAME230}+72002
    Set Test Variable  ${email}  ${firstname}${CUSERNAME1}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${CUSERNAME1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${CUR_DAY}
    ${C_date}=  Convert Date  ${CUR_DAY}  result_format=%d-%m-%Y
    Set Suite Variable   ${C_date}
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${resp}=   Create Sample Service  ${SERVICE12}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00    
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${clinicalNotes}=  Create Dictionary  symptoms=${symptoms}  allergies=${allergies}  diagnosis=${diagnosis}  complaints=${complaint}   misc_notes=${misc_notes}  observations=${observations}  vaccinationHistory=${vacc_history}  
   
    ${resp}=  Create MR   ${wid1}  ${bookingType[0]}  ${consultationMode[3]}  ${CUR_DAY}  ${status[0]}   clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadPrescriptionImage   ${mr_id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get by Criteria         account-eq=${pid}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                             200
    Should Be Equal As Strings           ${resp.json()['${id}']['files'][0]['account']}                    ${pid}
    Should Be Equal As Strings           ${resp.json()['${id}']['files'][0]['context']}                    ${context[3]}   
    Should Be Equal As Strings           ${resp.json()['${id}']['files'][0]['ownerType']}                  ${ownerType[0]} 
  

JD-TC-GetFileByCriteria-UH1

    [Documentation]    consumer login
      
    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get by Criteria          sharedType-eq=secureShare
    Log                                 ${resp.content}
    Should Be Equal As Strings           ${resp.status_code}    401
    Should Be Equal As Strings           ${resp.json()}         ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetFileByCriteria-UH2

    [Documentation]  Without login

    ${resp}=   Get by Criteria          sharedType-eq=secureShare
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}  419
    Should Be Equal As Strings          ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetFileByCriteria-UH3

    [Documentation]     get  files from jaldee drive - filetype: EMPTY

      
    ${resp}=  Encrypted Provider Login            ${PUSERNAME66}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get by Criteria          fileType-eq=${EMPTY}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings          ${resp.json()}    {}


JD-TC-GetFileByCriteria-UH4

    [Documentation]     get  files from jaldee drive - filetype: invalid
    
    ${resp}=  Encrypted Provider Login            ${PUSERNAME66}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get by Criteria          fileType-eq=00
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings          ${resp.json()}       {}


JD-TC-GetFileByCriteria-UH5

    [Documentation]     another provider login
    
    ${resp}=  Encrypted Provider Login            ${PUSERNAME1}  ${PASSWORD}
    Log                                 ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get by Criteria          fileType-eq=png
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings          ${resp.json()}     {}


JD-TC-GetFileByCriteria-15
   
    [Documentation]   get   Questionnaire Donation  file

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Log List  ${QnrChannel}
    Log List  ${QnrTransactionType}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${servicenames}
    Set Suite Variable   ${servicenames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Enable Disable Online Payment   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List  ${snames}  ${resp.json()[${i}]['name']}
    END

    Remove Values From List  ${servicenames}   ${NONE}
    Log  ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    Set Suite Variable   ${unique_snames}
    ${snames_len}=  Get Length  ${unique_snames}
    FOR  ${i}  IN RANGE   ${snames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${snames}  ${unique_snames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${s_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[3]}' in @{u_ttype}  Create Sample Service  ${unique_snames[${i}]}
        ${d_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[0]}' in @{u_ttype}   Create Sample Donation  ${unique_snames[${i}]}
    END
    clear_customer      ${PUSERNAME66} 
    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid12}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
 

    ${id}=  get_id  ${PUSERNAME66}
    Set Suite Variable  ${id}
   
    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${d_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${d_id}' != '${None}'
    END
    Set Suite Variable   ${d_id}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[0]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[0]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${d_id}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${con_id}   ${resp.json()['id']}

    ${don_amt}=   Random Int   min=500   max=1000  step=10
    ${don_amt}=  Convert To Number  ${don_amt}  1
    ${resp}=  Donation By Consumer  ${con_id}  ${d_id}  ${lid}  ${don_amt}  ${fname}  ${lname}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${don_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${don_id}  ${don_id[0]}

    ${resp}=  Get Consumer Donation By Id  ${don_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}    uid=${don_id}

    ${resp}=   Get Donation Questionnaire By Id   ${account_id}  ${d_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME12}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.CDonationQAnsUpload   ${cookie}  ${account_id}   ${don_id}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=   Get Donation Questionnaire By Id   ${account_id}  ${d_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

   

    ${resp}=  Get Consumer Donation By Id  ${don_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   # Check Answers   ${resp}  ${data}
    ${resp}=   Consumer Logout         
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login   ${PUSERNAME66}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200
 

    ${resp}=   Get by Criteria          account-eq=${account_id} 
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                            200
    Should Be Equal As Strings          ${resp.json()['${cid12}']['files'][0]['account']}                   ${account_id} 
    Should Be Equal As Strings          ${resp.json()['${cid12}']['files'][0]['ownerType']}                 ${ownerType[1]}
    Should Be Equal As Strings          ${resp.json()['${cid12}']['files'][0]['context']}                   ${context[17]}

    ${resp}=   Get by Criteria          contextType-eq=${context[17]} 
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                            200


JD-TC-GetFileByCriteria-16
    [Documentation]  filter context type waitlist
     
    ${CUSERPH0}=  Evaluate  ${CUSERPH}+100100521
    Set Suite Variable   ${CUSERPH0}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH0}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    # ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    # Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    # Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+5568520
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_B}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_B}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_B}${\n}
    Set Suite Variable  ${PUSERNAME_B}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid12}=  get_acc_id  ${PUSERNAME_B}
    Set Suite Variable  ${pid12}
    ${id}=  get_id  ${PUSERNAME_B}
    Set Suite Variable  ${id}
   

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_B}+15566174
    ${ph2}=  Evaluate  ${PUSERNAME_B}+25566174
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${businessName }      ${resp.json()['businessName']}

    ${resp}=  Get Consumer By Id  ${CUSERPH0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['userProfile']['id']}
    Set Suite Variable  ${fname}   ${resp.json()['userProfile']['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['userProfile']['lastName']}

    ${resp}=  AddCustomer  ${CUSERPH0}   firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}



    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${resp}=   Create Sample Service   ${SERV1} 
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${resp}=   Create Sample Service  ${SERV2}              
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${resp}=   Create Sample Service  ${SERV3}           
    Set Suite Variable    ${ser_id3}    ${resp}  
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=1
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  ${ser_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    sleep   5s
    ${msg}=  FakerLibrary.sentence
    Set Suite Variable  ${msg}


  
    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${MassCommunication}=  Set Variable   ${resp.json()['checkinMessages']['massCommunication']['Consumer_APP']} 
    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME_B}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    ${fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    
    ${resp}=  Consumer Mass Communication   ${cookie}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}  ${msg}    ${fileswithcaption}    ${wid1}  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${MassCommunication1}=  Replace String  ${MassCommunication}  [consumer]       ${fname} ${lname}
    # ${MassCommunication1}=  Replace String  ${MassCommunication1}  [service]       ${SERVICE1}
    ${MassCommunication1}=  Replace String  ${MassCommunication1}  [type]       booking
    ${MassCommunication1}=  Replace String  ${MassCommunication1}  [message]       ${msg}
    ${MassCommunication1}=  Replace String  ${MassCommunication1}  [brandName]     ${businessName}

    Set Suite Variable   ${MassCommunication1}
    Log   ${MassCommunication1}
 
    ${MassCommunication2}=  Replace String  ${MassCommunication}  [consumer]        ${fname} ${lname}
    # ${MassCommunication2}=  Replace String  ${MassCommunication2}  [service]       ${SERVICE2}
    ${MassCommunication2}=  Replace String  ${MassCommunication2}  [type]           booking
    ${MassCommunication2}=  Replace String  ${MassCommunication2}  [message]       ${msg}
    ${MassCommunication2}=  Replace String  ${MassCommunication2}  [brandName]     ${businessName}

    Set Suite Variable   ${MassCommunication2}

    sleep  3s


     
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${wid1}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${MassCommunication1}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID}
    Should Contain 	${resp.json()[2]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[2]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3
    Should Be Equal As Strings  ${resp.json()[3]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[3]['waitlistId']}         ${wid2}
    Should Be Equal As Strings  ${resp.json()[3]['msg']}                ${MassCommunication2}
    Should Be Equal As Strings  ${resp.json()[3]['receiver']['id']}     ${jdconID}
    # Should Be Equal As Strings  ${resp.json()[3]['attachements']}       []
    Should Contain 	${resp.json()[3]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[3]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    ${resp}=  Consumer Login  ${CUSERPH0}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   3s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${wid1}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${MassCommunication1}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID} 
    # Should Be Equal As Strings  ${resp.json()[2]['attachements']}       []
    Should Contain 	${resp.json()[2]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[2]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3
    Should Be Equal As Strings  ${resp.json()[3]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[3]['waitlistId']}         ${wid2}
    Should Be Equal As Strings  ${resp.json()[3]['msg']}                ${MassCommunication2}
    Should Be Equal As Strings  ${resp.json()[3]['receiver']['id']}     ${jdconID}
    # Should Be Equal As Strings  ${resp.json()[3]['attachements']}       []
    Should Contain 	${resp.json()[3]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[3]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_consumer_msgs  ${CUSERPH0}
    clear_provider_msgs  ${PUSERNAME_B}

   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get by Criteria          contextType-eq=${context[8]}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                            200
    Should Be Equal As Strings           ${resp.json()['${id}']['files'][0]['account']}                   ${pid12} 
    Should Be Equal As Strings           ${resp.json()['${id}']['files'][0]['ownerType']}                 ${ownerType[0]}
    Should Be Equal As Strings           ${resp.json()['${id}']['files'][0]['context']}                   ${context[8]}
