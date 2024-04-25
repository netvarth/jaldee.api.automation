*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Communication
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${waitlistedby}           PROVIDER
@{emptylist}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458

*** Test Cases ***    

JD-TC-SendMessageWithWL-1

    [Documentation]  Send Message With Waitelist   

    clear_location    ${PUSERNAME299}
    clear_service     ${PUSERNAME299}
    clear_queue       ${PUSERNAME299} 
    clear_customer    ${PUSERNAME299}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}
    Set Suite Variable  ${pdrname}  ${decrypted_data['userName']}

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable                    ${account_id}       ${resp.json()['id']}
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnum}=    Generate Random 555 Test Phone Number
    Set Suite Variable  ${cnum}
     
    ${resp}=  AddCustomer  ${cnum}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id2}    ${resp}
    ${resp}=   Get Location ById  ${loc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${tz2}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   db.subtract_timezone_time  ${tz}  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    Set Suite Variable    ${end_time}  
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity} 

    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id2}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}  
    # sleep  2s  
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}


    ${q_name2}=    FakerLibrary.name
    Set Suite Variable    ${q_name2}
    ${strt_time2}=   db.add_timezone_time  ${tz}  4  00
    Set Suite Variable    ${strt_time2}
    ${end_time2}=    db.add_timezone_time  ${tz}  5  00 
    Set Suite Variable    ${end_time2}  

    ${resp}=  Create Queue    ${q_name2}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time2}  ${end_time2}  ${parallel}   ${capacity}    ${loc_id2}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}   ${resp.json()}  
    # sleep  2s  
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid2[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}      personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${ser_name1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    FakerLibrary.firstname
    Set Suite variable    ${fileName}

    ${resp}    upload file to temporary location    ${file_action[0]}    ${provider_id}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessageWithWL-2

    [Documentation]  Send Message With Waitelist - multiple WL 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-SendMessageWithWL-3

    [Documentation]  Send Message With Waitelist - with two attachment

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachments2}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}  ${attachments2}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-SendMessageWithWL-4

    [Documentation]  Send Message With Waitelist - owner is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${empty}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-SendMessageWithWL-5

    [Documentation]  Send Message With Waitelist - owner is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${inv}=  FakerLibrary.Random Int

    ${attachments}=  Create Dictionary  owner=${inv}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessageWithWL-6

    [Documentation]  Send Message With Waitelist - file name is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${empty}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${FILE_NAME_NOT_FOUND}


JD-TC-SendMessageWithWL-7

    [Documentation]  Send Message With Waitelist - file size is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${empty}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${FILE_SIZE_ERROR}


JD-TC-SendMessageWithWL-8

    [Documentation]  Send Message With Waitelist - multiple WL 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${empty}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${FILE_TYPE_NOT_FOUND}


JD-TC-SendMessageWithWL-9

    [Documentation]  Send Message With Waitelist - order is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${empty}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessageWithWL-10

    [Documentation]  Send Message With Waitelist - drive id is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${empty}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INV_DRIVE_ID}


JD-TC-SendMessageWithWL-11

    [Documentation]  Send Message With Waitelist - drive id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${inv}=     FakerLibrary.Random Int

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${inv}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INV_DRIVE_ID}


JD-TC-SendMessageWithWL-12

    [Documentation]  Send Message With Waitelist - action is remove

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[2]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessageWithWL-13

    [Documentation]  Send Message With Waitelist - owner name is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${empty}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessageWithWL-14

    [Documentation]  Send Message With Waitelist - attachment is empty list

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment}=   Create List  
    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessageWithWL-15

    [Documentation]  Send Message With Waitelist - uuid is empty list

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List 

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${ENTER_UUID}


JD-TC-SendMessageWithWL-16

    [Documentation]  Send Message With Waitelist - uuid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}
    ${inv}=     FakerLibrary.Random Int

    ${uuid}=    Create List  ${inv}

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['${inv}']}      ${INVAL_UUID}


JD-TC-SendMessageWithWL-17

    [Documentation]  Send Message With Waitelist - message is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${empty}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${MASS_COMMUNICATION_NOT_EMPTY}


JD-TC-SendMessageWithWL-18

    [Documentation]  Send Message With Waitelist - email flag is false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[0]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessageWithWL-19

    [Documentation]  Send Message With Waitelist - sms flag is false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[0]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessageWithWL-20

    [Documentation]  Send Message With Waitelist - telegram flag is false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessageWithWL-21

    [Documentation]  Send Message With Waitelist - whats app flag is false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessageWithWL-22

    [Documentation]  Send Message With Waitelist - without login

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}


JD-TC-SendMessageWithWL-23

    [Documentation]  Send Message With Waitelist - with consumer login

    ${resp}=   Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}  ${NoAccess}


JD-TC-SendMessageWithWL-24

    [Documentation]  Send Message With Waitelist - with provider who dont have created any wl

    ${resp}=  Encrypted Provider Login  ${PUSERNAME298}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}  ${NO_PERMISSION}


JD-TC-SendMessageWithWL-25

    [Documentation]  Send Message With Waitelist - provider consumer login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${consumerPhone}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
    ${consumerFirstName}=   FakerLibrary.first_name
    Set Suite Variable  ${consumerFirstName}
    ${consumerLastName}=    FakerLibrary.last_name  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${consumerFirstName}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${consumerFirstName}   lastName=${consumerLastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${consumerId}  ${resp.json()[0]['id']}
    Should Be Equal As Strings    ${resp.json()[0]['id']}  ${consumerId}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}  ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}  ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()[0]['email']}  ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()[0]['gender']}  ${gender}
    Should Be Equal As Strings    ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}  ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['status']}  ${status[0]}
    Should Be Equal As Strings    ${resp.json()[0]['favourite']}  ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['phone_verified']}  ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['email_verified']}  ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['whatsAppNum']['countryCode']}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()[0]['whatsAppNum']['number']}  ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()[0]['telegramNum']['countryCode']}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()[0]['telegramNum']['number']}  ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()[0]['age']['year']}  ${ageyrs}
    Should Be Equal As Strings    ${resp.json()[0]['age']['month']}  ${agemonths}
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${account_id}
    ${fullName}   Set Variable    ${consumerFirstName} ${consumerLastName}
    Set Test Variable  ${fullName}

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${account_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}  ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  400
    Should Be Equal As Strings  ${resp.json()}  ${LOGIN_INVALID_URL}

JD-TC-SendMessageWithWL-26

    [Documentation]  Send Message With Waitlist - where waitlist status is canceled/Rejected
    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}




        ${reason}=  Random Element  ${cancelReason}
        ${msg}=   FakerLibrary.sentence
        Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=    Waitlist Action Cancel  ${wid2}  ${reason}  ${msg}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${uuid}=    Create List    ${wid2}  

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-SendMessageWithWL-27

    [Documentation]  Send Message With Waitlist - where wl status is Check-in
    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${resp}=  Waitlist Action   ${waitlist_actions[3]}   ${wid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.content}


    ${uuid}=    Create List    ${wid2}   

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-SendMessageWithWL-28

    [Documentation]  Send Message With Waitlist - where wl status is STARTED
    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id   ${wid}
    Log  ${resp.content}


    ${uuid}=    Create List    ${wid}   

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-SendMessageWithWL-29

    [Documentation]  Send Message With Waitlist - where appointment status is complete
    ${resp}=  Encrypted Provider Login  ${PUSERNAME299}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${resp}=  Waitlist Action   ${waitlist_actions[4]}   ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id   ${wid}
    Log  ${resp.content}


    ${uuid}=    Create List    ${wid}   

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

