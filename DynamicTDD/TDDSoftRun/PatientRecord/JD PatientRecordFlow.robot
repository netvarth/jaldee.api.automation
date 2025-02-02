*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Patient Record
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

@{emptylist}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt
${mp4file}      /ebs/TDD/MP4file.mp4
${mp3file}      /ebs/TDD/MP3file.mp3
${order}    0
${fileSize}    0.00458
${title1}    @sdf@123
${description1}    &^7gsdkqwrrf

${waitlistedby}           PROVIDER
${SERVICE1}               SERVICE1001
${SERVICE2}               SERVICE2002
${SERVICE3}               SERVICE3003
${SERVICE4}               SERVICE4004
${SERVICE5}               SERVICE3005
${SERVICE6}               SERVICE4006
${sample}                     4452135820

*** Test Cases ***

JD-TC-Patient Record Flow-1

    [Documentation]    Create a new Patient Record.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Suite Variable  ${iscorp_subdomains}
     Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  generate_firstname
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+9774502
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    202
     ${resp}=  Account Activation  ${PUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}
     Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}


    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
     Set Suite Variable  ${PUSERNAME_E}
     ${id}=  get_id  ${PUSERNAME_E}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}

    #  ${resp}=  Enable Disable Department  ${toggle[0]}
    #  Log   ${resp.json()}
    #  Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Enable Disable Department  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    Set Suite Variable  ${ser_id}  ${resp.json()['departments'][0]['serviceIds'][0]}

    ${lid}=  Create Sample Location

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    Set Suite Variable  ${email}  ${lastName}${primaryMobileNo}.${test_mail}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200   
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${cid}            ${resp.json()['providerConsumer']}
    Set Suite Variable    ${jconid}         ${resp.json()['id']}
    Set Suite Variable    ${proconfname}    ${resp.json()['firstName']}    
    Set Suite Variable    ${proconlname}    ${resp.json()['lastName']} 
    Set Suite Variable    ${fullname}       ${proconfname}${space}${proconlname}

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  
    # ${resp}=   Create Sample Service  ${SERVICE1}
    # Set Test Variable    ${ser_id1}    ${resp}  
    # ${resp}=   Create Sample Service  ${SERVICE2}
    # Set Test Variable    ${ser_id2}    ${resp}  
    # ${resp}=   Create Sample Service  ${SERVICE3}
    # Set Test Variable    ${ser_id3}    ${resp}  

    # ${q_name}=    FakerLibrary.name
    # ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   subtract_time  5  55
    # ${end_time}=    add_time  5  00 
    # ${parallel}=   Random Int  min=1   max=1
    # ${capacity}=  Random Int   min=130   max=200

    # ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${que_id1}   ${resp.json()}
    
    # ${waitlist_ids}=  Create List

    # ${desc}=   FakerLibrary.word
    # ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
            
    # ${wid}=  Get Dictionary Values  ${resp.json()}
    # Set Test Variable  ${wid${a}}  ${wid[0]}

    ${name}=  FakerLibrary.name
    Set Suite Variable    ${name}
    ${aliasName}=  FakerLibrary.name
    Set Suite Variable    ${aliasName}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${DAY1}

    ${resp}=    Create Case Category    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${category_id}    ${resp.json()['id']} 

    ${category}=  Create Dictionary  id=${category_id}  
    Set Suite Variable    ${category} 

    ${resp}=    Create Case Type    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${type_id}    ${resp.json()['id']}  

    ${type}=  Create Dictionary  id=${type_id} 
    Set Suite Variable    ${type}  
    ${doctor}=  Create Dictionary  id=${pid} 
    Set Suite Variable    ${doctor} 
    ${title}=  FakerLibrary.name
    Set Suite Variable    ${title}
    ${description}=  FakerLibrary.last_name
    Set Suite Variable    ${description}

     ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    Set Suite Variable  ${email}  ${lastName}${primaryMobileNo}.${test_mail}

    ${consumer}=  Create Dictionary  id=${cid} 
    Set Suite Variable    ${consumer} 

    ${resp}=    Create MR Case    ${category}  ${type}  ${doctor}  ${consumer}   ${title}  ${description}    
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${caseId}        ${resp.json()['id']}
    Set Suite Variable    ${caseUId}    ${resp.json()['uid']}

    ${resp}=    Get MR Case By UID   ${caseUId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname} 
    Should Be Equal As Strings    ${resp.json()['doctor']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['doctor']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['doctor']['lastName']}     ${pdrlname}
    Should Be Equal As Strings    ${resp.json()['type']['id']}     ${type_id} 
    Should Be Equal As Strings    ${resp.json()['category']['id']}     ${category_id} 
    Should Be Equal As Strings    ${resp.json()['createdDate']}     ${DAY1}

    ${med_name}=      FakerLibrary.name
    Set Suite Variable    ${med_name}
    ${frequency}=     FakerLibrary.word
    Set Suite Variable    ${frequency}
    ${duration}=      FakerLibrary.sentence
    Set Suite Variable    ${duration}
    ${instrn}=        FakerLibrary.sentence
    Set Suite Variable    ${instrn}
    ${dosage}=        FakerLibrary.sentence
    Set Suite Variable    ${dosage}
    ${type}=     FakerLibrary.word
    Set Suite Variable    ${type}
    ${clinicalNote}=     FakerLibrary.word
    Set Suite Variable    ${clinicalNote}
    ${clinicalNote1}=        FakerLibrary.sentence
    Set Suite Variable    ${clinicalNote1}
    ${type1}=        FakerLibrary.sentence
    Set Suite Variable    ${type1}


    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}

    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachments}=    Create Dictionary   action=${file_action[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}    driveId=${driveId}
    Log  ${attachments}
    Set Suite Variable    ${attachments}

    ${voiceAttachments}=    Create Dictionary   action=${file_action[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}    driveId=${driveId}
    Log  ${voiceAttachments}
    ${voiceAttachments}=  Create List   ${voiceAttachments}
    Set Suite Variable    ${voiceAttachments}

    ${resp}=    Create Section Template    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Section Template   ${caseUId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.json()[0]['enumName']}   ${}
    Set Suite Variable    ${temp_id}    ${resp.json()[0]['id']}
    Set Suite Variable    ${enumName}    ${resp.json()[0]['sectionType']}
    Set Suite Variable    ${temp_id1}    ${resp.json()[1]['id']}
    Set Suite Variable    ${enumName1}    ${resp.json()[1]['sectionType']}

    Set Suite Variable    ${temp_id2}    ${resp.json()[2]['id']}
    Set Suite Variable    ${enumName2}    ${resp.json()[2]['sectionType']}

    Set Suite Variable    ${temp_id3}    ${resp.json()[3]['id']}
    Set Suite Variable    ${enumName3}    ${resp.json()[3]['sectionType']}

    Set Suite Variable    ${temp_id4}    ${resp.json()[4]['id']}
    Set Suite Variable    ${enumName4}    ${resp.json()[4]['sectionType']}

    Set Suite Variable    ${temp_id5}    ${resp.json()[5]['id']}
    Set Suite Variable    ${enumName5}    ${resp.json()[5]['sectionType']}

    Set Suite Variable    ${temp_id6}    ${resp.json()[6]['id']}
    Set Suite Variable    ${enumName6}    ${resp.json()[6]['sectionType']}

    Set Suite Variable    ${temp_id7}    ${resp.json()[7]['id']}
    Set Suite Variable    ${enumName7}    ${resp.json()[7]['sectionType']}

    Set Suite Variable    ${temp_id8}    ${resp.json()[8]['id']}
    Set Suite Variable    ${enumName8}    ${resp.json()[8]['sectionType']}

    Set Suite Variable    ${temp_id9}    ${resp.json()[9]['id']}
    Set Suite Variable    ${enumName9}    ${resp.json()[9]['sectionType']}

    Set Suite Variable    ${temp_id9}    ${resp.json()[9]['id']}
    Set Suite Variable    ${enumName9}    ${resp.json()[9]['sectionType']}


    ${CHIEFCOMPLAINT}=  create Dictionary  chiefComplaint=${caption}
    Set Suite Variable    ${CHIEFCOMPLAINT}

    ${resp}=    Create Sections     ${caseUId}    ${pid}    ${temp_id}       ${enumName}    ${CHIEFCOMPLAINT}    ${attachments}   voiceAttachments=${voiceAttachments}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${history}=  Create List    ${caption}  ${caption}
    ${HISTORY}=  create Dictionary  history=${history}
    Set Suite Variable    ${HISTORY}

    ${resp}=    Create Sections     ${caseUId}    ${pid}    ${temp_id1}       ${enumName1}    ${HISTORY}    ${attachments}   voiceAttachments=${voiceAttachments}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}    Get MR Sections By Case     ${caseUId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dentalHistory}=  Create List    ${caption}  ${caption}
    ${DENTALHISTORY}=  create Dictionary  dentalHistory=${dentalHistory}
    Set Suite Variable    ${DENTALHISTORY}

    ${resp}=    Create Sections     ${caseUId}    ${pid}    ${temp_id2}       ${enumName2}    ${DENTALHISTORY}    ${attachments}   voiceAttachments=${voiceAttachments}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}    Get MR Sections By Case     ${caseUId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${medication}=  Create List    ${caption}  ${caption}
    ${MEDICATION}=  create Dictionary  medication=${medication}
    Set Suite Variable    ${MEDICATION}

    ${resp}=    Create Sections     ${caseUId}    ${pid}    ${temp_id3}       ${enumName3}    ${MEDICATION}    ${attachments}   voiceAttachments=${voiceAttachments}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}    Get MR Sections By Case     ${caseUId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    
