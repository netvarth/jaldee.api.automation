*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           random
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Variables ***

${self}     0
@{service_names}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458
${pdffile}      /ebs/TDD/sample.pdf
${domain}       healthCare
${subdomain}    dentists


*** Keywords ***

Create Treatment Plan

    [Arguments]      ${caseDto}   ${treatment}  ${works}  &{kwargs}
    ${caseDto}=  Create Dictionary  uid=${caseDto} 
    ${data}=  Create Dictionary    caseDto=${caseDto}   treatment=${treatment}  works=${works} 
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/treatment  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Treatment Plan
    RETURN  ${resp}


*** Test Cases ***

JD-TC-PreDeploymentAppointment-1

    [Documentation]  Appointment workflow for pre deployment.

    ${firstname}  ${lastname}  ${PUSERNAME_B}  ${LoginId}=  Provider Signup   Domain=${domain}   SubDomain=${subdomain}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}
    Set Test Variable  ${pdrname}  ${decrypted_data['userName']}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
    
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id}=  Create Sample Service  ${SERVICE1}      maxBookingsAllowed=20
    Set Test Variable  ${s_id}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'       
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=10  max=20
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}
    IF  ${resp.json()['availableSlots'][${j1}]['noOfAvailbleSlots']} == 0   
        Remove From List    ${slots}    ${slot1}
    END
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j1}]}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME20}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}   email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #.....Apply Label ..............

    clear_Label  ${PUSERNAME_B}

    ${label_id}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary  ${lbl_name}  ${lbl_value}

    ${resp}=  Add Label for Multiple Appointment   ${label_dict}  ${apptid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${lbl_name}=${lbl_value}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['label']}  ${label}

    #..... Send Message .............

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${caption1}=  Fakerlibrary.Sentence
    ${fileName}=    generate_filename
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${provider_id}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${apptid1}

    ${resp}=    Send Message With Appointment   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    #.... Send Attachment ............

    ${resp}=  Send Attachment From Appointment   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Appointment     ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence
    ${type}=     FakerLibrary.word
    ${clinicalNote}=     FakerLibrary.word
    ${clinicalNote1}=        FakerLibrary.sentence
    ${type1}=        FakerLibrary.sentence
   
    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    ${caption}=  Fakerlibrary.Sentence
   
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${caption1}=  Fakerlibrary.Sentence
   
    ${resp}    upload file to temporary location    ${LoanAction[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${prescriptionAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}   driveId=${driveId}
    Log  ${prescriptionAttachments}
    ${prescriptionAttachments}=  Create List   ${prescriptionAttachments}
    Set Test Variable    ${prescriptionAttachments}

    ${mrPrescriptions}=  Create Dictionary  medicineName=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    ${note}=  FakerLibrary.Text  max_nb_chars=42 

    ${resp}=    Create Prescription    ${cid}    ${pid}      ${html}     ${mrPrescriptions}    prescriptionNotes=${note}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${prescription_uid}   ${resp.json()}

    ${resp}=    Get Prescription By Provider consumer Id   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${referenceId}   ${resp.json()[0]['referenceId']}   
    Set Test Variable  ${uid}   ${resp.json()[0]['uid']}
    Set Test Variable  ${prescriptionStatus}   ${resp.json()[0]['prescriptionStatus']}

    ${resp1}=  Get Prescription By UID    ${prescription_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

    #......... Share Prescription to patient...........

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${resp}=    Share Prescription To Patient   ${prescription_uid}    ${message}    ${bool[1]}      
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
    
    # ${resp}=  Share Case Pdf  ${case_id}  ${bool[1]}  ${bool[0]}  ${consumer}  ${doctor}  ${message}  ${medium}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    #....... Treatment plan ...........

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}

    ${resp}=    Create Treatment Plan    ${case_id}    ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Test Variable    ${treatmentId}        ${resp.json()}
