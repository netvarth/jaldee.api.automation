*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${bmpfile}     /ebs/TDD/first.bmp
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt

*** Test Cases ***

JD-TC-Provider Note-1
    [Documentation]   create Note by valid provider with attachment as jpg file.

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_J}=  Evaluate  ${PUSERNAME}+55668872
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_J}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_J}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_J}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_J}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_J}${\n}
    Set Suite Variable  ${PUSERNAME_J}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_J}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME_J}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_J}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   get_place
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
    ${sTime}=  db.add_timezone_time  ${tz}  0  15
    ${eTime}=  db.add_timezone_time  ${tz}   0  45
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
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
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph2}=  Evaluate  ${PUSERNAME23}+72547
    Set Test Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${m_jid}=  Random Int  min=10  max=50
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${ph2}  ${m_jid}
    Set Suite Variable  ${cid}  ${resp.json()}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    Set Suite Variable    ${ser_name2} 
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Suite Variable    ${ser_id2}    ${resp}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}   
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}   
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_J}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${cookie}
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence

    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_J}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Variable Should Exist   ${resp.content}  ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}
    Should Contain 	${resp.json()[0]}   attachment
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpg
    Variable Should Exist   ${resp.content}  ${caption}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_J}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${msg1}=  Fakerlibrary.sentence
    ${caption1}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg1}  ${caption1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_J}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                 200
    Variable Should Exist   ${resp.content}  ${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}         ${uuid}
    Should Contain 	${resp.json()[0]}   attachment
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpg
    Variable Should Exist   ${resp.content}  ${caption1}
    
    Variable Should Exist   ${resp.content}  ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['uId']}         ${uuid}
    Should Contain 	${resp.json()[1]}   attachment
    Dictionary Should Contain Key  ${resp.json()[1]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachment'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachment'][0]['s3path']}   .jpg
    Variable Should Exist   ${resp.content}  ${caption}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_J}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${msg2}=  Fakerlibrary.sentence
    ${caption2}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg2}  ${caption2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                 200
    Variable Should Exist   ${resp.content}  ${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}         ${uuid}
    Should Contain 	${resp.json()[0]}   attachment
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpg
    Variable Should Exist   ${resp.content}  ${caption2}
    
    Variable Should Exist   ${resp.content}  ${msg1}
    Should Be Equal As Strings  ${resp.json()[1]['uId']}         ${uuid}
    Should Contain 	${resp.json()[1]}   attachment
    Dictionary Should Contain Key  ${resp.json()[1]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachment'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachment'][0]['s3path']}   .jpg
    Variable Should Exist   ${resp.content}  ${caption1}
    
    Variable Should Exist   ${resp.content}  ${msg}
    Should Be Equal As Strings  ${resp.json()[2]['uId']}         ${uuid}
    Should Contain 	${resp.json()[2]}   attachment
    Dictionary Should Contain Key  ${resp.json()[2]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[2]['attachment'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[2]['attachment'][0]['s3path']}   .jpg
    Variable Should Exist   ${resp.content}  ${caption}
    
    # ${comm_msg}=   FakerLibrary.sentence 
    # ${resp}=  Create provider Note   ${uuid}   ${comm_msg}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # sleep   4s
    # ${resp}=  get provider Note  ${uuid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}                 200
    # Should Be Equal As Strings  ${resp.json()[0]['note']}           ${comm_msg}
    # Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}


    # ${comm_msg1}=   FakerLibrary.sentence 
    # ${resp}=  Create provider Note   ${uuid}   ${comm_msg1}
    # Should Be Equal As Strings  ${resp.status_code}  200   
    # ${resp}=  get provider Note  ${uuid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['note']}           ${comm_msg1}
    # Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}
    # Should Be Equal As Strings  ${resp.json()[1]['note']}           ${comm_msg}
    # Should Be Equal As Strings  ${resp.json()[1]['uId']}     ${uuid}   

    # ${comm_msg2}=   FakerLibrary.sentence     
    # ${resp}=  Create provider Note   ${uuid}   ${comm_msg2}
    # Should Be Equal As Strings  ${resp.status_code}  200    
    # ${resp}=  get provider Note  ${uuid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['note']}           ${comm_msg2}
    # Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}
    # Should Be Equal As Strings  ${resp.json()[1]['note']}           ${comm_msg1}
    # Should Be Equal As Strings  ${resp.json()[1]['uId']}     ${uuid}
    # Should Be Equal As Strings  ${resp.json()[2]['note']}           ${comm_msg}
    # Should Be Equal As Strings  ${resp.json()[2]['uId']}     ${uuid}    

JD-TC-Provider Note-2
    [Documentation]   create Note by valid provider with attachment as png file.

    clear_queue      ${PUSERNAME184}
    clear_location   ${PUSERNAME184}
    clear_service    ${PUSERNAME184}
    clear_customer   ${PUSERNAME184}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME184}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME184}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}   ${pngfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Should Be Equal As Strings  ${resp.json()[0]['note']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}
    Should Contain 	${resp.json()[0]}   attachment
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .png
    Should Be Equal As Strings  ${resp.json()[0]['attachment'][0]['caption']}     ${caption} 


JD-TC-Provider Note-3
    [Documentation]   create Note by valid provider with attachment as pdf file.

    clear_queue      ${PUSERNAME182}
    clear_location   ${PUSERNAME182}
    clear_service    ${PUSERNAME182}
    clear_customer   ${PUSERNAME182}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME182}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    Set Suite Variable    ${ser_name2} 
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Suite Variable    ${ser_id2}    ${resp}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}   
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME182}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${cookie}
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}   ${pdffile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Should Be Equal As Strings  ${resp.json()[0]['note']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}
    Should Contain 	${resp.json()[0]}   attachment
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .pdf
    Should Be Equal As Strings  ${resp.json()[0]['attachment'][0]['caption']}     ${caption} 

JD-TC-Provider Note-4
    [Documentation]   create Note by valid provider with attachment as jpeg file.

    clear_queue      ${PUSERNAME148}
    clear_location   ${PUSERNAME148}
    clear_service    ${PUSERNAME148}
    clear_customer   ${PUSERNAME148}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME148}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME148}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}   ${jpegfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Should Be Equal As Strings  ${resp.json()[0]['note']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}
    Should Contain 	${resp.json()[0]}   attachment
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpeg
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpeg
    Should Be Equal As Strings  ${resp.json()[0]['attachment'][0]['caption']}     ${caption} 


JD-TC-Provider Note-5
    [Documentation]   create Note by valid provider without message.

    clear_queue      ${PUSERNAME191}
    clear_location   ${PUSERNAME191}
    clear_service    ${PUSERNAME191}
    clear_customer   ${PUSERNAME191}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME191}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME191}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${EMPTY}  ${caption}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Should Be Equal As Strings  ${resp.json()[0]['note']}    ${EMPTY}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}
    Should Contain 	${resp.json()[0]}   attachment
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachment'][0]['caption']}     ${caption} 


JD-TC-Provider Note-6
    [Documentation]   create Note by valid provider without caption.

    clear_queue      ${PUSERNAME192}
    clear_location   ${PUSERNAME192}
    clear_service    ${PUSERNAME192}
    clear_customer   ${PUSERNAME192}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME192}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME192}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${EMPTY} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Should Be Equal As Strings  ${resp.json()[0]['note']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}
    Should Contain 	${resp.json()[0]}   attachment
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachment'][0]['caption']}     ${EMPTY} 

JD-TC-Provider Note-7
    [Documentation]   create Note by valid provider with attachment as gif file.

    clear_queue      ${PUSERNAME183}
    clear_location   ${PUSERNAME183}
    clear_service    ${PUSERNAME183}
    clear_customer   ${PUSERNAME183}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME183}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    
     
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    Set Suite Variable    ${ser_name2} 
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Suite Variable    ${ser_id2}    ${resp} 

    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME183}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${cookie}
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}   ${giffile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Should Be Equal As Strings  ${resp.json()[0]['note']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}



JD-TC-Provider Note-8
    [Documentation]   create Note by valid provider with attachment as doc file.

    clear_queue      ${PUSERNAME187}
    clear_location   ${PUSERNAME187}
    clear_service    ${PUSERNAME187}
    clear_customer   ${PUSERNAME187}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME187}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME187}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}   ${docfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Should Be Equal As Strings  ${resp.json()[0]['note']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}


JD-TC-Provider Note-9
    [Documentation]   create Note by valid provider with attachment as txt file.

    clear_queue      ${PUSERNAME189}
    clear_location   ${PUSERNAME189}
    clear_service    ${PUSERNAME189}
    clear_customer   ${PUSERNAME189}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME189}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME189}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}   ${txtfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Should Be Equal As Strings  ${resp.json()[0]['note']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}


JD-TC-Provider Note-UH1
    [Documentation]   create note by another providers uuid 

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # ${comm_msg}=   FakerLibrary.sentence 
    # Set Suite Variable   ${comm_msg}
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_WAITLIST}"
    # ${resp}=  Create provider Note   ${uuid}   ${comm_msg}
    # Should Be Equal As Strings  ${resp.status_code}  401
    # Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

    
JD-TC-Provider Note-UH2
    [Documentation]   create note by consumer
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    # ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}
    Log  ${resp.json()}

    # ${resp}=  Create provider Note   ${uuid}   how are you
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"    
    
JD-TC-Provider Note-UH3
    [Documentation]   create note  without login
    
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}
    Log  ${resp.json()}
    # ${resp}=  Create provider Note   ${uuid}   ${comm_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  419
    # Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"    

JD-TC-Provider Note-UH4
    [Documentation]   create note  with invalid waitlist id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_J}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   -114  ${msg}  ${caption}
    Log  ${resp.json()}
    # ${resp}=  Create provider Note   0   ${comm_msg}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_WAITLIST}" 


JD-TC-Provider Note-UH6
    [Documentation]   create Note by valid provider with attachment as sh file.

    clear_queue      ${PUSERNAME188}
    clear_location   ${PUSERNAME188}
    clear_service    ${PUSERNAME188}
    clear_customer   ${PUSERNAME188}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}   ${shfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${IMAGE_TYPE_NOT_SUPPORTED}"

