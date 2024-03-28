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
${self}      0
&{attachment}   size=0.0  sharedId=0
@{empty_attachment}   ${attachment}

*** Test Cases ***

JD-TC-GetWaitlistAttachment-1

    [Documentation]   Add waitlist attachment as jpg file and get the attachment.
    
    clear_queue      ${PUSERNAME178}
    clear_location   ${PUSERNAME178}
    clear_service    ${PUSERNAME178}
    clear_customer   ${PUSERNAME178}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME178}
    Set Suite Variable   ${acc_id} 

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
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
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}   
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cookie}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.CWLAttachment   ${cookie}   ${acc_id}   ${uuid}   ${caption}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}


JD-TC-GetWaitlistAttachment-2

    [Documentation]   Add waitlist attachment as png file and get the attachment.
    
    clear_queue      ${PUSERNAME178}
    clear_location   ${PUSERNAME178}
    clear_service    ${PUSERNAME178}
    clear_customer   ${PUSERNAME178}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME178}
    Set Test Variable   ${acc_id} 

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   
    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.CWLAttachment   ${cookie}   ${acc_id}   ${uuid}   ${caption}  ${pngfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .png
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}

JD-TC-GetWaitlistAttachment-3

    [Documentation]   Add waitlist attachment as pdf file and get the attachment.
    
    clear_queue      ${PUSERNAME178}
    clear_location   ${PUSERNAME178}
    clear_service    ${PUSERNAME178}
    clear_customer   ${PUSERNAME178}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME178}
    Set Test Variable   ${acc_id} 

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.CWLAttachment   ${cookie}   ${acc_id}   ${uuid}   ${caption}  ${pdffile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .pdf
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}

JD-TC-GetWaitlistAttachment-4

    [Documentation]   Add waitlist attachment by as jpeg file and get the attachment.
    
    clear_queue      ${PUSERNAME178}
    clear_location   ${PUSERNAME178}
    clear_service    ${PUSERNAME178}
    clear_customer   ${PUSERNAME178}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME178}
    Set Test Variable   ${acc_id} 

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.CWLAttachment   ${cookie}   ${acc_id}   ${uuid}   ${caption}  ${jpegfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .jpeg
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .jpeg
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}

JD-TC-GetWaitlistAttachment-5

    [Documentation]   Add waitlist attachment by without caption and get the attachment.
    
    clear_queue      ${PUSERNAME178}
    clear_location   ${PUSERNAME178}
    clear_service    ${PUSERNAME178}
    clear_customer   ${PUSERNAME178}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME178}
    Set Test Variable   ${acc_id} 

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Imageupload.CWLAttachment   ${cookie}   ${acc_id}   ${uuid}   ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${EMPTY} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}


JD-TC-GetWaitlistAttachment-6

    [Documentation]   Add waitlist attachment as gif file and get the attachment.
    
    clear_queue      ${PUSERNAME178}
    clear_location   ${PUSERNAME178}
    clear_service    ${PUSERNAME178}
    clear_customer   ${PUSERNAME178}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME178}
    Set Test Variable   ${acc_id} 

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.CWLAttachment   ${cookie}   ${acc_id}   ${uuid}   ${caption}  ${giffile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .gif
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .gif
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}


JD-TC-GetWaitlistAttachment-UH1

    [Documentation]   Get waitlist attachment with another consumer's waitlist id.
    
    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   ${EMPTY}
    # Should Be Equal As Strings  ${resp.status_code}  404
    # Should Be Equal As Strings  "${resp.json()}"   "${INVALID_WAITLIST}"

JD-TC-GetWaitlistAttachment-UH2

    [Documentation]   Get waitlist attachment by provider login.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   ${EMPTY}
    # Should Be Equal As Strings  ${resp.status_code}  404
    # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_WAITLIST}"    

JD-TC-GetWaitlistAttachment-UH3

    [Documentation]   Get waitlist attachment with invalid waitlist id.
    
    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}  0000
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   ${EMPTY}
    # Should Be Equal As Strings  ${resp.status_code}  404
    # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_WAITLIST}" 


JD-TC-GetWaitlistAttachment-UH4

    [Documentation]   Add waitlist attachment as doc file and get the attachment.
    
    clear_queue      ${PUSERNAME178}
    clear_location   ${PUSERNAME178}
    clear_service    ${PUSERNAME178}
    clear_customer   ${PUSERNAME178}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME178}
    Set Test Variable   ${acc_id} 

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.CWLAttachment   ${cookie}   ${acc_id}   ${uuid}   ${caption}  ${docfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .doc
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .doc
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}


JD-TC-GetWaitlistAttachment-UH5

    [Documentation]   Add waitlist attachment as sh file and get the attachment.
    
    clear_queue      ${PUSERNAME178}
    clear_location   ${PUSERNAME178}
    clear_service    ${PUSERNAME178}
    clear_customer   ${PUSERNAME178}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME178}
    Set Test Variable   ${acc_id} 

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.CWLAttachment   ${cookie}   ${acc_id}   ${uuid}   ${caption}  ${shfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${IMAGE_TYPE_NOT_SUPPORTED}"


JD-TC-GetWaitlistAttachment-UH6

    [Documentation]   Add waitlist attachment as txt file and get the attachment.
    
    clear_queue      ${PUSERNAME178}
    clear_location   ${PUSERNAME178}
    clear_service    ${PUSERNAME178}
    clear_customer   ${PUSERNAME178}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME178}
    Set Test Variable   ${acc_id} 

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.CWLAttachment   ${cookie}   ${acc_id}   ${uuid}   ${caption}  ${txtfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .txt
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .txt
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}


JD-TC-GetWaitlistAttachment-UH7

    [Documentation]   Add waitlist attachment by provider login.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME178}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   ${EMPTY}
    # Should Be Equal As Strings  ${resp.status_code}  404
    # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_WAITLIST}"    


JD-TC-GetWaitlistAttachment-UH8

    [Documentation]   Get waitlist attachment for an appointment.
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_queue    ${PUSERNAME99}
    clear_service  ${PUSERNAME99}
    clear_rating    ${PUSERNAME99}
    clear_customer   ${PUSERNAME99}

    ${pid}=  get_acc_id  ${PUSERNAME99}
    Should Be Equal As Strings    ${resp.status_code}   200
 
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    clear_appt_schedule   ${PUSERNAME99}

    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
   
    ${SERVICE2}=   FakerLibrary.name
    ${s_id2}=  Create Sample Service  ${SERVICE2}
   
    ${SERVICE3}=   FakerLibrary.name
    ${s_id3}=  Create Sample Service  ${SERVICE3}
   
    ${SERVICE4}=   FakerLibrary.name
    ${s_id4}=  Create Sample Service  ${SERVICE4}
   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}      ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${DAY2}=  db.add_timezone_date  ${tz}  11      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}      ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id3}  ${s_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${cid1}=  get_id  ${CUSERNAME6}
    
    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set TEst Variable  ${apptid1}  ${apptid[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME6}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${pid}   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   ${EMPTY}
    # Should Be Equal As Strings  ${resp.status_code}  404
    # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_WAITLIST}"    


JD-TC-GetWaitlistAttachment-UH9

    [Documentation]   Get waitlist attachment without adding attachment.
    
    clear_queue      ${PUSERNAME178}
    clear_location   ${PUSERNAME178}
    clear_service    ${PUSERNAME178}
    clear_customer   ${PUSERNAME178}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME178}
    Set Test Variable   ${acc_id} 

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    FOR  ${i}  IN RANGE   5
        ${ser_names}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    Set Test Variable    ${ser_name1}    ${ser_names[0]}
    # ${ser_name1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}
    Set Test Variable    ${ser_name2}    ${ser_names[1]}  
    # ${ser_name2}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}   
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   [{'size': 0.0, 'sharedId': 0}]
    # Should Be Equal As Strings  ${resp.status_code}  404
    # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_WAITLIST}"    
