*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        MR
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Keywords ***
# Create MR With uuid
#     [Arguments]  ${uuid}  ${bookingType}  ${consultationMode}  ${type}  ${clinicalNote}     ${notes}  ${mrConsultationDate}  ${state}    ${action}    ${owner}    ${fileName}    ${fileSize}    ${caption}    ${fileType}    ${order}   @{vargs}
    
#     ${Attachment}=    Create Dictionary    action=${action}    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    caption=${caption}    fileType=${fileType}      order=${order}
#     ${Attachment}=  Create List    ${Attachment}

#     ${clinicalNotes}=  Create Dictionary  type=${type}  clinicalNotes=${clinicalNote}  attachments=${Attachment} 
#     ${clinicalNotes}=  Create List   ${clinicalNotes}

#     ${len}=  Get Length  ${vargs}
#     ${prescriptionsList}=  Create List  

#     FOR    ${index}    IN RANGE    ${len}   
#         Exit For Loop If  ${len}==0
#         Append To List  ${prescriptionsList}  ${vargs[${index}]}
#     END

#     ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${notes}  

#    ${data}=  Create Dictionary    bookingType=${bookingType}  consultationMode=${consultationMode}  clinicalNotes=${clinicalNotes}  prescriptions=${prescriptions}   mrConsultationDate=${mrConsultationDate}  state=${state}
#    ${data}=  json.dumps  ${data}
#    Check And Create YNW Session
#    ${resp}=  POST On Session  ynw  /provider/mr/${uuid}  data=${data}  expected_status=any
#    RETURN  ${resp}

Create MR With uuid
    [Arguments]  ${uuid}  ${bookingType}  ${consultationMode}   ${mrConsultationDate}  ${state}    &{kwargs}

   ${data}=  Create Dictionary    bookingType=${bookingType}  consultationMode=${consultationMode}    mrConsultationDate=${mrConsultationDate}  state=${state}     
   FOR  ${key}  ${value}  IN  &{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
   END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/mr/${uuid}  data=${data}  expected_status=any
   RETURN  ${resp}

clinical Notes Attachments
    [Arguments]  ${type}  ${clinicalNote}   @{vargs}  &{kwargs}

    ${len}=  Get Length  ${vargs}
    ${AttachmentList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${AttachmentList}  ${vargs[${index}]}
    END

    ${clinicalNotes}=  Create Dictionary  type=${type}  clinicalNotes=${clinicalNote}  attachments=${AttachmentList} 
    RETURN  ${clinicalNotes}

*** Variables ***
${SERVICE1}               SERVICE1
${SERVICE2}               SERVICE2
${SERVICE3}               SERVICE3
${SERVICE4}               SERVICE4
${SERVICE5}               SERVICE3
${SERVICE6}               SERVICE4
${self}                   0

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

*** Test Cases ***

JD-TC-CreateMR-1
    [Documentation]   Create Medical Record for a waitlist(Walk-in).
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+8850021
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
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${pid}=  get_acc_id  ${PUSERNAME_C}
    # Set Suite Variable  ${pid}

    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${eTime}=  db.add_timezone_time  ${tz}   5  45
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}

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

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id1}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  0  30
    ${end_time}=    db.add_timezone_time  ${tz}  5  00  
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

    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${Pres_notes}=         FakerLibrary.sentence
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
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments1}

    ${Notes}=    clinical Notes Attachments    ${type}  ${clinicalNote}    ${aadhaarAttachments}    ${aadhaarAttachments}

    ${Notes1}=    clinical Notes Attachments    ${type1}  ${clinicalNote1}    ${aadhaarAttachments}    ${aadhaarAttachments1}

    ${clinicalNotes}=  Create List   ${Notes}    ${Notes1}
   
    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}

    ${prescriptionsList}=  Create List   ${pre_list}

    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}
    
    ${resp}=  Create MR With uuid  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id1}   ${resp.json()}

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}  ${type}  ${clinicalNote}    ${notes}  ${CUR_DAY}  ${status[0]}    ${LoanAction[0]}    ${pid}  ${jpgfile}  ${fileSize}  ${caption}  ${fileType}   ${order}   ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateMR-2
    [Documentation]   Create Medical Record for multiple waitlist(walk-in).

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+7850022
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_D}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_D}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_D}${\n}
    Set Suite Variable  ${PUSERNAME_D}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    ${pid0}=  get_acc_id  ${PUSERNAME_D}
    Set Suite Variable  ${pid0}

    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_D}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_D}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    Set Suite Variable    ${DAY1}
    ${sTime}=  db.add_timezone_time  ${tz}  0  15
    ${eTime}=  db.add_timezone_time  ${tz}   0  45
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${pid}  ${resp.json()['id']}
    

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
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   

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

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id2}    ${resp} 
    ${resp}=   Get Location ById  ${loc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}   
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${resp}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable    ${ser_id3}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    ${end_time}=    db.add_timezone_time  ${tz}  3  00  
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id2}  ${ser_id2}   ${ser_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${FUT_DAY}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id2}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id3}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${Pres_notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${clinicalNote}=        FakerLibrary.sentence
    ${type}=        FakerLibrary.sentence
    ${clinicalNote1}=        FakerLibrary.sentence
    ${type1}=        FakerLibrary.sentence

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid0}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid0}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments1}

    ${Notes}=    clinical Notes Attachments    ${type}  ${clinicalNote}    ${aadhaarAttachments}    ${aadhaarAttachments}

    ${Notes1}=    clinical Notes Attachments    ${type1}  ${clinicalNote1}    ${aadhaarAttachments}    ${aadhaarAttachments1}

    ${clinicalNotes}=  Create List   ${Notes}    ${Notes1}

    Set Suite Variable    ${clinicalNotes}
   
    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}

    ${prescriptionsList}=  Create List   ${pre_list}

    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}
    
    ${resp}=  Create MR With uuid  ${wid2}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id2}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    ${clinicalNote}=        FakerLibrary.sentence
    ${type}=        FakerLibrary.sentence
    ${clinicalNote1}=        FakerLibrary.sentence
    ${type1}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}

    # ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid0}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    # Log  ${aadhaarAttachments}

    # ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid0}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    # Log  ${aadhaarAttachments1}

    # ${Notes}=    clinical Notes Attachments    ${type}  ${clinicalNote}    ${aadhaarAttachments}    ${aadhaarAttachments1}

    # ${Notes1}=    clinical Notes Attachments    ${type1}  ${clinicalNote1}    ${aadhaarAttachments}    ${aadhaarAttachments1}


    
    ${resp}=  Create MR With uuid    ${wid3}   ${bookingType[0]}  ${consultationMode[3]}    ${CUR_DAY}  ${status[0]}    prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}        
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id3}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateMR-3
    [Documentation]   Create Medical Record for a waitlist(online-in).

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id2}  ${CUR_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${pid0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${Pres_notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${clinicalNote}=        FakerLibrary.sentence
    Set Suite Variable  ${clinicalNote}
    ${type}=        FakerLibrary.sentence
    Set Suite Variable  ${type}
    ${clinicalNote1}=        FakerLibrary.sentence
    Set Suite Variable  ${clinicalNote1}
    ${type1}=        FakerLibrary.sentence
    Set Suite Variable  ${type1}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid0}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}
    Set Suite Variable  ${aadhaarAttachments}


    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid0}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments1}
    Set Suite Variable  ${aadhaarAttachments1}


    ${Notes}=    clinical Notes Attachments    ${type}  ${clinicalNote}    ${aadhaarAttachments}    ${aadhaarAttachments}
    Set Suite Variable  ${Notes}

    ${Notes1}=    clinical Notes Attachments    ${type1}  ${clinicalNote1}    ${aadhaarAttachments1}    ${aadhaarAttachments1}
    Set Suite Variable  ${Notes1}
   
    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}

    ${prescriptionsList}=  Create List   ${pre_list}

    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}
    
    ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}   ${notes}  ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateMR-4
    [Documentation]   Create Medical Record with consultation mode EMAIL for waitlist.

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id2}  ${CUR_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${pid0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${Pres_notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    ${prescriptionsList}=  Create List   ${pre_list}
    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}
    # ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[0]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[0]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateMR-5
    [Documentation]   Create Medical Record with consultation mode PHONE for waitlist.

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${Pres_notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    ${prescriptionsList}=  Create List   ${pre_list}
    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}
    Set Suite Variable  ${prescriptions}
    
    # ${resp}=  Create MR With uuid  ${waitlist_id}   ${bookingType[0]}  ${consultationMode[1]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[1]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  

JD-TC-CreateMR-6
    [Documentation]   Create Medical Record with consultation mode VIDEO for waitlist.

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[2]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[2]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-CreateMR-7
    [Documentation]   Create Medical Record without details.

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${DAY2}=  db.add_timezone_date  ${tz}   2
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${DAY1}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    # ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${DAY1}  ${status[0]} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateMR-8
    [Documentation]   Create Medical Record with two prescriptions.

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${DAY3}=  db.add_timezone_date  ${tz}  3
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${DAY1}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${Pres_notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${DAY1}  ${status[0]}  ${pre_list}  ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateMR-9
    [Documentation]   Create Medical Record with a different date in future.

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  db.add_timezone_date  ${tz}   1
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${DAY}  ${status[0]}  ${pre_list} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateMR-10
    [Documentation]   Create Medical Record with inactive status.

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${DAY}=  db.add_timezone_date  ${tz}   1
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${DAY1}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    # ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${DAY}  ${status[1]}  ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY}    ${status[1]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateMR-11
    [Documentation]   Create Medical Record for family member's waitlist(online check-in).

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}
       
    ${DAY}=  db.add_timezone_date  ${tz}   1
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${DAY1}  ${ser_id1}  ${cnote}  ${bool[0]}  ${cidfor}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    # ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}

    # ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}   ${DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateMR-12
    [Documentation]   Create Medical Record for family member's waitlist(walkin check-in).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${id}  ${f_name}  ${l_name}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_id}  ${resp.json()}
    
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${id}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${mem_id}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wait_id1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wait_id1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${wait_id1}  ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}   ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR With uuid  ${wait_id1}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateMR-13
    [Documentation]   Create Medical Record with a different date.

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  db.add_timezone_date  ${tz}   1
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${DAY1}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}   ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateMR-14
    [Documentation]   Create Medical Record without prescription.

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${DAY3}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${DAY3}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${json}=  evaluate    json.loads('''${resp.content}''')    json
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    # ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
   
    # ${resp}=  Create MR With uuid  ${waitlist_id}   ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${CUR_DAY}  ${status[0]} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY3}    ${status[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateMR-15
    [Documentation]   Create Medical Record for an appointment(online-in).
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+7850033
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Suite Variable  ${PUSERNAME_A}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${pid1}=  get_acc_id  ${PUSERNAME_A}
    # Set Suite Variable  ${pid1}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_A}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_A}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}

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
    
    ${resp}=  Enable Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    clear_service   ${PUSERNAME_A}
    clear_location  ${PUSERNAME_A}   
    clear_appt_schedule   ${PUSERNAME_A} 
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${SERVICE2}=   FakerLibrary.name
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.add_timezone_time  ${tz}  1  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${eTime1}=  db.add_timezone_time  ${tz}  2  45
    
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${sTime2}=  db.add_timezone_time  ${tz}  2  50
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}   

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()} 

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid1}
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
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cid}=  get_id  ${CUSERNAME7}   
    Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get Consumer Appointment By Id   ${pid1}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}   ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateMR-16
    [Documentation]   Create Medical Record for an appointment(walk-in).
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${DAY1}=   db.add_timezone_date  ${tz}   2
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}   ${DAY1}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateMR-UH1
    [Documentation]   Create Medical Record for another provider's waitlist.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}   ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}

    ${resp}=  Create MR With uuid  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${NO_PERMISSION}"
    

JD-TC-CreateMR-UH2
    [Documentation]   Create Medical Record for waitlist having MR.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}   ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}

    ${resp}=  Create MR With uuid  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings   "${resp.json()}"   "${MR_ALREADY_CREATED}"
    
JD-TC-CreateMR-UH3
    [Documentation]   Create Medical Record with booking type APPT for waitlist.

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cons_id}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[1]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}   ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[1]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${INVALID_BOOKING_TYPE}"

JD-TC-CreateMR-UH4
    [Documentation]   Create Medical Record with booking type FOLLOWUP for waitlist.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${waitlist_id}   ${bookingType[2]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[2]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${INVALID_BOOKING_TYPE}"

JD-TC-CreateMR-UH5
    [Documentation]   Create Medical Record without login.

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${waitlist_id}   ${bookingType[2]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}   ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[2]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-CreateMR-UH6
    [Documentation]   Create Medical Record with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${waitlist_id}   ${bookingType[2]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[2]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-CreateMR-UH7
    [Documentation]   Create Medical Record for an appointment with booking type as TOKEN.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${DAY1}=   db.add_timezone_date  ${tz}   3
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME14}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}   ${DAY1}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}

    ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${INVALID_BOOKING_TYPE}"
   
JD-TC-CreateMR-UH8
    [Documentation]   Create Medical Record for an appointment with booking type as FOLLOWUP.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${DAY1}=   db.add_timezone_date  ${tz}   4
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME15}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[2]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}   ${DAY1}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}

    ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[2]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${INVALID_BOOKING_TYPE}"

JD-TC-CreateMR-UH9
    [Documentation]   Create Medical Record for an invalid appointment id.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=   db.add_timezone_date  ${tz}   4
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  5c1784c9-d594-43a3-9464-da649bc44as3_appt   ${bookingType[1]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${DAY1}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}

    ${resp}=  Create MR With uuid   5c1784c9-d594-43a3-9464-da649bc44as3_appt  ${bookingType[1]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${INVALID_APPOINTMENT_UID}"

JD-TC-CreateMR-UH10
    [Documentation]   Create Medical Record for an invalid waitlist id.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=   db.add_timezone_date  ${tz}   4
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  659f95e8-158b-4d0c-a7d5-2c5e15d6d7a4_wlt   ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${DAY1}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}

    ${resp}=  Create MR With uuid   5c1784c9-d594-43a3-9464-da649bc44as3_appt  ${bookingType[0]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_APPT_ID}
    # Should Be Equal As Strings   "${resp.json()}"   "${INVALID_WTLST_ID}"

JD-TC-CreateMR-UH11
    [Documentation]   Create Medical Record for a cancelled waitlist.

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=   FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[2]}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME27}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${waitlist_id}   ${bookingType[0]}  ${consultationMode[1]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}

    ${resp}=  Create MR With uuid   ${waitlist_id}  ${bookingType[0]}  ${consultationMode[1]}      ${CUR_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${CAN_NOT_CRETAE_MR_WL}"
    
JD-TC-CreateMR-UH12
    [Documentation]   Create Medical Record for a future waitlist(walk-in).

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+54031
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_D}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_D}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_D}${\n}
    Set Suite Variable  ${PUSERNAME_D}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${pid0}=  get_acc_id  ${PUSERNAME_D}
    # Set Suite Variable  ${pid0}

    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_D}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_D}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid0}  ${resp.json()['id']}

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
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   

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

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id2}    ${resp} 
    ${resp}=   Get Location ById  ${loc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}   
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id2}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    ${end_time}=    db.add_timezone_time  ${tz}  3  00  
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id2}  ${ser_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${FUT_DAY}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id2}  ${que_id2}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${Pres_notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence
    
    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    # ${resp}=  Create MR With uuid  ${wid2}  ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${FUT_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}

    ${resp}=  Create MR With uuid   ${wid2}  ${bookingType[0]}  ${consultationMode[3]}  ${FUT_DAY}    ${status[0]}   prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Set Test Variable     ${resp.json()}      "${MEDICAL_RECORD_WL_FUTURE_DATE}"