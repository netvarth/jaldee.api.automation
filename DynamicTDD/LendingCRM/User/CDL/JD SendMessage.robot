*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        CDL Communication
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ApiKeywords.robot
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***

${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${order}    0
@{emptylist}


*** Test Cases ***

JD-TC-SendMessage-1

    [Documentation]   Provider send a message to a jaldee consumer without any attachment.


    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id2}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id1}  ${decrypted_data['id']}

    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id1}  ${userType[0]}  ${consumer_id2}  ${userType[3]}  ${messageType[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []

JD-TC-SendMessage-2

    [Documentation]   Provider send a message to a jaldee consumer with one attachment.


    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id3}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id2}  ${decrypted_data['id']}

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id2}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id2}  ${userType[0]}  ${consumer_id3}  ${userType[3]}  ${messageType[0]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessage-3

    [Documentation]   Provider send a message to a jaldee consumer with more than one attachment.


    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id4}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id3}  ${decrypted_data['id']}

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id3}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${pngfile}
    ${attachment_list1}=  Create Dictionary         owner=${provider_id3}   fileName=${pngfile}    fileSize= 0.00458     caption=${caption1}     fileType=${fileType1}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id3}  ${userType[0]}  ${consumer_id4}  ${userType[3]}  ${messageType[0]}  ${attachment_list}  ${attachment_list1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessage-4

    [Documentation]   Provider send a message to a partner with one attachment.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME34}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableBranchMaster']}  ${bool[1]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${locname}  ${resp.json()['place']}
        
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${locname}  ${resp.json()[0]['place']}
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${phone}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealername}=  FakerLibrary.bs
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${partid1}  ${resp.json()['id']}
    Set Test Variable  ${partuid1}  ${resp.json()['uid']} 

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${partid1}  ${userType[3]}  ${messageType[0]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessage-5

    [Documentation]   User send a message to a jaldee consumer with one attachment.


    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME95}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${MUSERNAME95}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User 
    Set Test Variable  ${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U2}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U2}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${u_id1}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${u_id1}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[0]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessage-6

    [Documentation]   Provider send a message to a jaldee consumer without any message.


    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id2}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id1}  ${decrypted_data['id']}

    clear_customer   ${MUSERNAME20}

    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${EMPTY}  ${provider_id1}  ${userType[0]}  ${consumer_id2}  ${userType[3]}  ${messageType[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   

JD-TC-SendMessage-UH1

    [Documentation]   Provider send a message to another provider with one attachment.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME25}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider1}  ${decrypted_data['id']}
    
    ${resp}=  ProviderLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME26}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${provider1}  ${userType[3]}  ${messageType[0]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}   "${INVALID_CONSUMER_ID}"


JD-TC-SendMessage-UH2

    [Documentation]   Consumer send a message to a provider with one attachment.


    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${consumer_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${consumer_id}  ${userType[0]}  ${provider_id}  ${userType[3]}  ${messageType[0]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}   "${INVALID_PROVIDER_ID}"


JD-TC-SendMessage-UH3

    [Documentation]   create a user in one location and partner in another location , then user try to send message to that partner.


    ${resp}=  Encrypted Provider Login  ${MUSERNAME87}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableBranchMaster']}  ${bool[1]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${locname}  ${resp.json()['place']}
        
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${locname}  ${resp.json()[0]['place']}
    END

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${MUSERNAME87}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User 
    Set Test Variable  ${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U2}  ${resp.json()['mobileNo']}

    ${locId1}=  Create Sample Location
    Set Test Variable  ${locId1}

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name

    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId1}    ${status[0]} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${phone}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealername}=  FakerLibrary.bs
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}     partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${partid1}  ${resp.json()['id']}
    Set Test Variable  ${partuid1}  ${resp.json()['uid']} 

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U2}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${partid1}  ${userType[3]}  ${messageType[0]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}   "${INVALID_CONSUMER_ID}"


JD-TC-SendMessage-UH4

    [Documentation]   Provider send a message to a jaldee consumer without provider_id.


    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id2}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id1}  ${decrypted_data['id']}

    clear_customer   ${MUSERNAME20}

    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${EMPTY}  ${userType[0]}  ${consumer_id2}  ${userType[3]}  ${messageType[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}   "${INVALID_USER_ID}"


JD-TC-SendMessage-UH5

    [Documentation]   Provider send a message to a jaldee consumer without consumer id.


    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id2}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id1}  ${decrypted_data['id']}

    clear_customer   ${MUSERNAME20}

    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id1}  ${userType[0]}  ${EMPTY}  ${userType[3]}  ${messageType[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}   "${INVALID_USER_ID}"