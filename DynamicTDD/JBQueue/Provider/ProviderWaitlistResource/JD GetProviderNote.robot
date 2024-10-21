*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

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
JD-TC-Get Provider Note-1
    [Documentation]   get provider note valid provider

    # clear_queue      ${HLPUSERNAME29}
    # clear_location   ${HLPUSERNAME29}
    # clear_service    ${HLPUSERNAME29}
    clear_customer   ${HLPUSERNAME29}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME29}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['timezone']} 
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${HLPUSERNAME29}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${cookie}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    ${msg1}=  Fakerlibrary.sentence
    ${caption1}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg1}  ${caption1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                 200
    Variable Should Exist   ${resp.content}  ${msg1}
    Should Be Equal As Strings  ${resp.json()[1]['uId']}         ${uuid}
    Should Contain 	${resp.json()[1]}   attachment
    Dictionary Should Contain Key  ${resp.json()[1]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachment'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachment'][0]['s3path']}   .jpg
    Variable Should Exist   ${resp.content}  ${caption1}
 
    Variable Should Exist   ${resp.content}  ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}         ${uuid}
    Should Contain 	${resp.json()[0]}   attachment
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachment'][0]['s3path']}   .jpg
    Variable Should Exist   ${resp.content}  ${caption}
     
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
    
    Variable Should Exist   ${resp.content}  ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['uId']}         ${uuid}
    Should Contain 	${resp.json()[1]}   attachment
    Dictionary Should Contain Key  ${resp.json()[1]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachment'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachment'][0]['s3path']}   .jpg
    Variable Should Exist   ${resp.content}  ${caption}
    
    Variable Should Exist   ${resp.content}  ${msg1}
    Should Be Equal As Strings  ${resp.json()[2]['uId']}         ${uuid}
    Should Contain 	${resp.json()[2]}   attachment
    Dictionary Should Contain Key  ${resp.json()[2]['attachment'][0]}   s3path
    Should Contain  ${resp.json()[2]['attachment'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachment'][0]}   thumbPath
    Should Contain  ${resp.json()[2]['attachment'][0]['s3path']}   .jpg
    Variable Should Exist   ${resp.content}  ${caption1}
    
    # ${comm_msg}=   FakerLibrary.sentence 
    # ${resp}=  Create provider Note   ${uuid}   ${comm_msg}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # sleep  2s  
    # ${resp}=  get provider Note  ${uuid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}                 200
    # Should Be Equal As Strings  ${resp.json()[0]['note']}           ${comm_msg}
    # Should Be Equal As Strings  ${resp.json()[0]['uId']}            ${uuid}
    # ${comm_msg1}=   FakerLibrary.sentence 
    # ${resp}=  Create provider Note   ${uuid}   ${comm_msg1}
    # Should Be Equal As Strings  ${resp.status_code}  200   
    # ${resp}=  get provider Note  ${uuid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['note']}           ${comm_msg1}
    # Should Be Equal As Strings  ${resp.json()[0]['uId']}            ${uuid}
    # Should Be Equal As Strings  ${resp.json()[1]['note']}           ${comm_msg}
    # Should Be Equal As Strings  ${resp.json()[1]['uId']}            ${uuid}   
    # ${comm_msg2}=   FakerLibrary.sentence     
    # ${resp}=  Create provider Note   ${uuid}   ${comm_msg2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200    
    # ${resp}=  get provider Note  ${uuid}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['note']}           ${comm_msg2}
    # Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}
    # Should Be Equal As Strings  ${resp.json()[1]['note']}           ${comm_msg1}
    # Should Be Equal As Strings  ${resp.json()[1]['uId']}     ${uuid}
    # Should Be Equal As Strings  ${resp.json()[2]['note']}           ${comm_msg}
    # Should Be Equal As Strings  ${resp.json()[2]['uId']}     ${uuid}    


JD-TC-Get Provider Note-2
    [Documentation]   Get Provider Note by valid provider with attachment as png file.

    # clear_queue      ${HLPUSERNAME29}
    # clear_location   ${HLPUSERNAME29}
    # clear_service    ${HLPUSERNAME29}
    clear_customer   ${HLPUSERNAME29}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME29}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}  
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${HLPUSERNAME29}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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

JD-TC-Get Provider Note-3
    [Documentation]   Get Provider Note by valid provider with attachment as pdf file.

    # clear_queue      ${HLPUSERNAME29}
    # clear_location   ${HLPUSERNAME29}
    # clear_service    ${HLPUSERNAME29}
    clear_customer   ${HLPUSERNAME29}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME29}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${loc_id1}=  Create Sample Location
        ${resp}=   Get Location ById  ${loc_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${loc_id1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END 
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${HLPUSERNAME29}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${cookie}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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


JD-TC-Get Provider Note-4
    [Documentation]   Get Provider Note by valid provider with attachment as jpeg file.

    # clear_queue      ${HLPUSERNAME29}
    # clear_location   ${HLPUSERNAME29}
    # clear_service    ${HLPUSERNAME29}
    clear_customer   ${HLPUSERNAME29}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME29}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}  
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${HLPUSERNAME29}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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


JD-TC-Get Provider Note-5
    [Documentation]   Get Provider Note by valid provider with attachment as gif file.

    # clear_queue      ${HLPUSERNAME29}
    # clear_location   ${HLPUSERNAME29}
    # clear_service    ${HLPUSERNAME29}
    clear_customer   ${HLPUSERNAME29}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME29}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['timezone']} 
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${HLPUSERNAME29}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${cookie}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}   ${giffile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Should Be Equal As Strings  ${resp.json()[0]['note']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}



JD-TC-Get Provider Note-6
    [Documentation]   Get Provider Note by valid provider with attachment as txt file.

    # clear_queue      ${HLPUSERNAME29}
    # clear_location   ${HLPUSERNAME29}
    # clear_service    ${HLPUSERNAME29}
    clear_customer   ${HLPUSERNAME29}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME29}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}  
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${HLPUSERNAME29}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}   ${txtfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Should Be Equal As Strings  ${resp.json()[0]['note']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}


JD-TC-Get Provider Note-7
    [Documentation]   Get Provider Note by valid provider with attachment as doc file.

    # clear_queue      ${HLPUSERNAME29}
    # clear_location   ${HLPUSERNAME29}
    # clear_service    ${HLPUSERNAME29}
    clear_customer   ${HLPUSERNAME29}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME29}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}  
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${HLPUSERNAME29}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}   ${docfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  get provider Note  ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Should Be Equal As Strings  ${resp.json()[0]['note']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['uId']}     ${uuid}

JD-TC-Get Provider Note-UH1
    [Documentation]   get provider note  by consumer

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME29}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${account_id}=  get_acc_id  ${HLPUSERNAME29}
    
    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${CUSERNAME3}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Send Otp For Login    ${CUSERNAME3}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Verify Otp For Login   ${CUSERNAME3}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME3}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  get provider Note  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"    
    
JD-TC-Get Provider Note-UH2
    [Documentation]  get provider note   without login

    ${resp}=  get provider Note  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"   
    
JD-TC-Get Provider Note-UH3
    [Documentation]   get provider note  by valid invalid use 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME29}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  get provider Note   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_WAITLIST}"
    # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_CONSUMER}"

JD-TC-Get Provider Note-UH6
    [Documentation]   Get Provider Note by valid provider with attachment as sh file.

    # clear_queue      ${HLPUSERNAME29}
    # clear_location   ${HLPUSERNAME29}
    # clear_service    ${HLPUSERNAME29}
    clear_customer   ${HLPUSERNAME29}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME29}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}  
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${HLPUSERNAME29}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.WaitlistNote   ${cookie}   ${uuid}  ${msg}  ${caption}   ${shfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${IMAGE_TYPE_NOT_SUPPORTED}"
