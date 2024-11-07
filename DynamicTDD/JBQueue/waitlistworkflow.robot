*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
# Variables         /ebs/TDD/varfiles/providers.py
# Variables         /ebs/TDD/varfiles/consumerlist.py 
# Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables          ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py

*** Variables ***
${self}         0
@{service_names}
&{Emptydict}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458
${pdffile}      /ebs/TDD/sample.pdf
${domain}       healthCare
${subdomain}    dentists

${var_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${data_file}              ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt

*** Test Cases ***
JD-TC-PreDeploymentWaitlist-1
    [Documentation]   Waitlist workflow for pre-deployment.

    # ${firstname}  ${lastname}  ${PUSERNAME_A}  ${LoginId}=  Provider Signup     Domain=${domain}   SubDomain=${subdomain}
    # Set Suite Variable  ${PUSERNAME_A}
    # ${num}=  find_last  ${var_file}
    # ${num}=  Evaluate   ${num}+1
    # Append To File  ${data_file}  ${LoginId} - ${PASSWORD}${\n}
    # Append To File  ${var_file}  PUSERNAME${num}=${LoginId}${\n}

    ${PUSERNAME_A}=  Set Variable  ${PUSERNAME3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}
    Set Suite Variable  ${pdrname}  ${decrypted_data['userName']}

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}   
        ${resp}=   Enable Waitlist
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    IF  ${resp.json()['onlinePresence']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${EMPTY}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

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

    ${resp}=  GetCustomer  
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        # ${NewCustomer}    Generate random string    10    123456789
        # ${NewCustomer}    Convert To Integer  ${NewCustomer}
        ${NewCustomer}=    Generate Random 555 Number
        Set Suite variable   ${NewCustomer}
        Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
        ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}   email=${pc_emailid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
        Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
    END

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}

    ${resp}=    Get Queues
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp}=    Create Sample Queue     
        Set Suite Variable  ${s_id}  ${resp['service_id']}
        Set Suite Variable  ${qid}   ${resp['queue_id']}

        ${resp}=    Get Queues
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=    Get Queue ById  ${qid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=  FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${wid}  ${resp.json()['parent_uuid']}
    ELSE
        Set Test Variable   ${qid}   ${resp.json()[0]['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[1]}     waitlistStatus-eq=${wl_status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${prepay_wl_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${prepay_wl_len}

        ${resp1}=  Waitlist Action  ${waitlist_actions[2]}   ${resp.json()[${i}]['ynwUuid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

    END

    ${desc}=  FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${wid}  ${resp.json()['parent_uuid']}


    #.....Apply Label ..............
    ${label_id}=   Create Sample Label

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary    ${lbl_name}    ${lbl_value}
    ${resp}=  Add Label for Multiple Waitlist   ${label_dict}    ${wid}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #..... Send Message .............

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${caption1}=  Fakerlibrary.Sentence
    ${fileName}=    generate_filename
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${provider_id}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}
    Set Suite Variable    ${S3_url}    ${resp.json()[0]['url']}

    ${resp}=    Upload File To S3    ${S3_url}      ${jpgfile}

    ${resp}=    Update Status File Share    ${QnrStatus[1]}     ${driveId}

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #.... Send Attachment ............

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${caption1}=  Fakerlibrary.Sentence
    ${fileName}=    generate_filename
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${provider_id}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId1}    ${resp.json()[0]['driveId']}
    Set Suite Variable    ${S3_url1}    ${resp.json()[0]['url']}

    ${resp}=    Upload File To S3    ${S3_url1}      ${jpgfile}

    ${resp}=    Update Status File Share    ${QnrStatus[1]}     ${driveId1}


    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId1}  action=${file_action[0]}  ownerName=${pdrname}

    ${resp}=  Send Attachment From Waitlist    ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Waitlist     ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #..........Prescription creation ............

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


    ${resp}    upload file to temporary location    ${LoanAction[0]}    ${provider_id}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${prescriptionAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${provider_id}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}   driveId=${driveId}
    Log  ${prescriptionAttachments}
    ${prescriptionAttachments}=  Create List   ${prescriptionAttachments}
    Set Suite Variable    ${prescriptionAttachments}

    ${mrPrescriptions}=  Create Dictionary  medicineName=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    Set Suite Variable    ${mrPrescriptions}
    ${note}=  FakerLibrary.Text  max_nb_chars=42 

    ${resp}=    Create Prescription    ${cid}    ${provider_id}      ${html}     ${mrPrescriptions}    prescriptionNotes=${note}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${prescription_uid}   ${resp.json()}

    ${resp}=    Get Prescription By Provider consumer Id   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${referenceId}   ${resp.json()[0]['referenceId']}   
    Set Suite Variable  ${uid}   ${resp.json()[0]['uid']}
    Set Suite Variable  ${prescriptionStatus}   ${resp.json()[0]['prescriptionStatus']}
    

    ${resp1}=  Get Prescription By UID    ${prescription_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200


    #......... Share Prescription to patient...........

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${resp}=    Share Prescription To Patient   ${prescription_uid}    ${message}    ${bool[1]} 
    # ${bool[1]}       ${bool[1]}    ${bool[1]}    ${bool[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}

    #......... Share Prescription to thirdparty...........

    ${fname}=  generate_firstname
    Set Test Variable  ${emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${message}     ${emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}

    #.......... Case Creation and share case............

    ${doctor}=  Create Dictionary  id=${provider_id} 
    ${consumer}=  Create Dictionary  id=${cid} 
    ${title}=  FakerLibrary.name

    ${resp}=  Create Case   ${title}  ${doctor}  ${consumer}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${case_id}   ${resp.json()['uid']}

    ${message}=  FakerLibrary.sentence
    ${medium}=  Create Dictionary  email=${bool[1]} 
    
    ${resp}=  Share Case Pdf  ${case_id}  ${bool[1]}  ${bool[0]}  ${consumer}  ${doctor}  ${message}  ${medium}     html=${html}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #....... Treatment plan ...........

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}

    ${resp}=    Create Treatment Plan    ${case_id}    ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Test Variable    ${treatmentId}        ${resp.json()}
