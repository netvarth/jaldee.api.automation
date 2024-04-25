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

JD-TC-Getauditlog-1
    [Documentation]   Get mr auditlog for a waitlist(Walk-in).
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+7830011
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
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}

    ${pid}=  get_acc_id  ${PUSERNAME_C}
    Set Suite Variable  ${pid}

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

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${C_date}=  Convert Date  ${CUR_DAY}  result_format=%d-%m-%Y
    Set Suite Variable   ${C_date}
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
    Set Suite Variable  ${aadhaarAttachments}


    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments1}

    ${Notes}=    clinical Notes Attachments    ${type}  ${clinicalNote}    ${aadhaarAttachments}    ${aadhaarAttachments}

    ${Notes1}=    clinical Notes Attachments    ${type1}  ${clinicalNote1}    ${aadhaarAttachments}    ${aadhaarAttachments1}

    ${clinicalNotes}=  Create List   ${Notes}    ${Notes1}
    Set Suite Variable  ${clinicalNotes}
   
    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}

    ${prescriptionsList}=  Create List   ${pre_list}
    
    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}
    Set Suite Variable  ${prescriptions}

    ${resp}=  Create MR With uuid  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id1}   ${resp.json()}

    # ${resp}=  Create MR With uuid  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}  ${complaint}  ${symptoms}  ${allergies}  ${vacc_history}  ${observations}  ${diagnosis}  ${misc_notes}  ${notes}  ${CUR_DAY}  ${status[0]}  ${pre_list}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

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
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
   
    ${MR_Description}=  Format String   ${MR_Description}    ${cid1}
    ${PRE_Description}=  Format String   ${PRE_Description}    ${cid1}
    ${CLINI_Description}=  Format String   ${CLINI_Description}  ${cid1}

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
  
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[2]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${CLINI_Description}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${PRE_Description}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${MR_Description}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}

    
JD-TC-Getauditlog-2
 
    [Documentation]   Get mr auditlog with create another prescription for a mr 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${med_name1}=      FakerLibrary.name
    ${frequency1}=     FakerLibrary.word
    ${duration1}=      FakerLibrary.sentence
    ${instrn1}=        FakerLibrary.sentence
    ${dosage1}=        FakerLibrary.sentence
    ${notes1}=          FakerLibrary.sentence

    ${pre_list1}=  Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  duration=${duration1}  instructions=${instrn1}  dosage=${dosage1}
    
    ${resp}=  Create MR prescription by mr id   ${mr_id1}  ${notes1}  ${pre_list1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['frequency']}      ${frequency1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['duration']}       ${duration1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['instructions']}   ${instrn1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['medicine_name']}  ${med_name1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['dosage']}         ${dosage1}
    Should Be Equal As Strings  ${resp.json()['notes']}                                  ${notes1}

   
    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${MR_Description}=  Format String   ${MR_Description}    ${cid1}
    ${PRE_Description}=  Format String   ${PRE_Description}    ${cid1}
    ${CLINI_Description}=  Format String   ${CLINI_Description}  ${cid1}

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[2]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${CLINI_Description}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${PRE_Description}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${PRE_Description}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[3]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[3]['Description']}       ${MR_Description}
    Should Be Equal As Strings  ${resp.json()[3]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[3]['DateTime']}          ${C_date} ${ctime}


 
JD-TC-Getauditlog-3
 
    [Documentation]   Get  mr auditlog with update prescription

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
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
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id3}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME12}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
   
    # ${med_name11}=    FakerLibrary.name
    # ${frequency11}=   FakerLibrary.word
    # ${duration11}=   FakerLibrary.sentence
    # ${instrn11}=   FakerLibrary.sentence
    # ${resp}=  Update MR prescription   ${mr_id3}   ${med_name11}  ${frequency11}  ${duration11}  ${instrn11}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get MR prescription   ${mr_id3} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['duration']}              ${duration11}
    # Should Be Equal As Strings  ${resp.json()[0]['frequency']}             ${frequency11}
    # Should Be Equal As Strings  ${resp.json()[0]['instructions']}          ${instrn11}
    # Should Be Equal As Strings  ${resp.json()[0]['medicine_name']}         ${med_name11}
    
    ${med_name1}=      FakerLibrary.name
    ${frequency1}=     FakerLibrary.word
    ${duration1}=      FakerLibrary.sentence
    ${instrn1}=        FakerLibrary.sentence
    ${dosage1}=        FakerLibrary.sentence
    ${notes1}=          FakerLibrary.sentence

    ${pre_list1}=  Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  duration=${duration1}  instructions=${instrn1}  dosage=${dosage1}
    
    ${resp}=  Update MR prescription   ${mr_id3}  ${notes1}  ${pre_list1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['frequency']}      ${frequency1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['duration']}       ${duration1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['instructions']}   ${instrn1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['medicine_name']}  ${med_name1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['dosage']}         ${dosage1}
    Should Be Equal As Strings  ${resp.json()['notes']}                                  ${notes1}

    ${MR_Description}=  Format String   ${MR_Description}    ${cid2}
    ${PRE_Description}=  Format String   ${PRE_Description}    ${cid2}
    ${CLINI_Description}=  Format String   ${CLINI_Description}  ${cid2}
    ${PRE_UpdateDescription}=  Format String   ${PRE_UpdateDescription}    ${mr_id3}

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[2]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${CLINI_Description}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[4]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${PRE_UpdateDescription}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${PRE_Description}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[3]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[3]['Description']}       ${MR_Description}
    Should Be Equal As Strings  ${resp.json()[3]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[3]['DateTime']}          ${C_date} ${ctime}

    
JD-TC-Getauditlog-4
 
    [Documentation]   Get auditlog with update clinical note

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${symptoms1}=      FakerLibrary.name
    ${allergies1}=     FakerLibrary.word
    ${diagnosis1}=     FakerLibrary.sentence
    ${complaints1}=    FakerLibrary.sentence
    ${misc_notes1}=    FakerLibrary.word
    ${observations1}=  FakerLibrary.sentence
    ${vaccinationHistory1}=  FakerLibrary.sentence

    ${clinicalNote1}=        FakerLibrary.sentence
    ${type1}=        FakerLibrary.sentence

    ${resp}=  Update MR clinical notes   ${mr_id3}   ${type1}  ${clinicalNote1}    ${aadhaarAttachments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type1}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote1}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}              ${caption}
   
    ${MR_Description}=  Format String      ${MR_Description}     ${cid2}
    ${PRE_Description}=  Format String     ${PRE_Description}    ${cid2}
    ${CLINI_Description}=  Format String   ${CLINI_Description}  ${cid2}
    ${PRE_UpdateDescription}=  Format String   ${PRE_UpdateDescription}       ${mr_id3}
    ${CLINI_UpdateDescription}=  Format String   ${CLINI_UpdateDescription}    ${mr_id3}

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[5]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${CLINI_UpdateDescription}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[2]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${CLINI_Description}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[4]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${PRE_UpdateDescription}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[3]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[3]['Description']}       ${PRE_Description}
    Should Be Equal As Strings  ${resp.json()[3]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[3]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[4]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[4]['Description']}       ${MR_Description}
    Should Be Equal As Strings  ${resp.json()[4]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[4]['DateTime']}          ${C_date} ${ctime}


JD-TC-Getauditlog-5
 
    [Documentation]   Get auditlog with consultation mode EMAIL for a online waitlist.

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+7850126
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
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id1}  ${decrypted_data['id']}
    Set Suite Variable  ${userName1}  ${decrypted_data['userName']}
    # Set Suite Variable    ${id1}    ${resp.json()['id']} 
    # Set Suite Variable    ${userName1}    ${resp.json()['userName']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_D}${\n}
    Set Suite Variable  ${PUSERNAME_D}

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
    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id2}    ${resp} 
    ${resp}=   Get Location ById  ${loc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

    ${resp}=   Get Location ById  ${loc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time1}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${strt_time1}
    ${end_time}=    add_timezone_time  ${tz}  3  00    
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time1}  ${end_time}  ${parallel}   ${capacity}    ${loc_id2}  ${ser_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${cusername}  ${resp.json()['userName']}
    

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id2}  ${CUR_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${wid2}  ${bookingType[0]}  ${consultationMode[0]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id2}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME6}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid2}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}
    
    ${MR_Description_name}=  Format String   ${MR_Description_name}    ${cusername}
    ${PRE_Description_name}=  Format String   ${PRE_Description_name}    ${cusername}
    ${CLINI_Description_name}=  Format String   ${CLINI_Description_name}  ${cusername}

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[2]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${CLINI_Description_name}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName1}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${PRE_Description_name}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName1}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${MR_Description_name}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName1}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}

JD-TC-Getauditlog-6
 
    [Documentation]   Get auditlog without create a prescription and clinical notes in mr 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=   db.get_time_by_timezone  ${tz}
    ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[0]}   ${CUR_DAY}  ${status[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME4}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}

    ${MR_Description}=  Format String   ${MR_Description}    ${cid}
    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${MR_Description}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${med_name1}=      FakerLibrary.name
    ${frequency1}=     FakerLibrary.word
    ${duration1}=      FakerLibrary.sentence
    ${instrn1}=        FakerLibrary.sentence
    ${dosage1}=        FakerLibrary.sentence
    ${notes1}=          FakerLibrary.sentence

    ${pre_list1}=  Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  duration=${duration1}  instructions=${instrn1}  dosage=${dosage1}
    
    ${resp}=  Create MR prescription by mr id   ${mr_id}  ${notes1}  ${pre_list1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['frequency']}      ${frequency1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['duration']}       ${duration1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['instructions']}   ${instrn1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['medicine_name']}  ${med_name1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['dosage']}         ${dosage1}
    Should Be Equal As Strings  ${resp.json()['notes']}                                  ${notes1}

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Getauditlog-7
 
    [Documentation]   Get auditlog without create a mr clinical notes 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${med_name1}=      FakerLibrary.name
    ${frequency1}=     FakerLibrary.word
    ${duration1}=      FakerLibrary.sentence
    ${instrn1}=        FakerLibrary.sentence
    ${notes}=          FakerLibrary.sentence
    ${prescriptions}=  Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  duration=${duration1}  instructions=${instrn1}
    ${prescriptions}=  Create List  ${prescriptions}
    ${pre_list}=       Create Dictionary  prescriptionsList=${prescriptions}  notes=${notes} 
   
    ${ctime}=   db.get_time_by_timezone  ${tz}
    ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[0]}   ${CUR_DAY}  ${status[0]}   prescriptions=${pre_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME7}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes']}                     []
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}

    ${MR_Description}=  Format String   ${MR_Description}    ${cid}
    ${PRE_Description}=  Format String   ${PRE_Description}    ${cid}
    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${PRE_Description}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${MR_Description}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

   

JD-TC-Getauditlog-8
 
    [Documentation]   Get auditlog without create a mr prescription 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${symptoms1}=      FakerLibrary.name
    ${allergies1}=     FakerLibrary.word
    ${diagnosis1}=     FakerLibrary.sentence
    ${complaints1}=    FakerLibrary.sentence
    ${misc_notes1}=    FakerLibrary.word
    ${observations1}=  FakerLibrary.sentence
    ${vaccinationHistory1}=  FakerLibrary.sentence
    ${clinicalNotes}=  Create Dictionary  symptoms=${symptoms1}  allergies=${allergies1}  diagnosis=${diagnosis1}  complaints=${complaints1}   misc_notes=${misc_notes1}  observations=${observations1}  vaccinationHistory=${vaccinationHistory1}  
   
    ${ctime}=   db.get_time_by_timezone  ${tz}
    ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[0]}   ${CUR_DAY}  ${status[0]}   clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME8}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList']}     []
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}


    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${MR_Description}=  Format String   ${MR_Description}    ${cid}
    ${CLINI_Description}=  Format String   ${CLINI_Description}  ${cid}

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[2]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${CLINI_Description}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${MR_Description}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}


JD-TC-Getauditlog-9
    [Documentation]   Get auditlog here create a prescription for family member's waitlist.

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    ${firstname0}=  FakerLibrary.first_name
    ${lastname0}=  FakerLibrary.last_name
    ${dob0}=  FakerLibrary.Date
    ${gender0}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname0}  ${lastname0}  ${dob0}  ${gender0}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id0}  ${resp.json()}
    
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${mem_id0}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=5
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id0}
   
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
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${mem_id0}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}     ${firstname0}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}      ${lastname0}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}

    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence
    ${notes}=          FakerLibrary.sentence

    ${pre_list1}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR prescription by mr id   ${mr_id}  ${notes}  ${pre_list1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['frequency']}      ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['duration']}       ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['instructions']}   ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['medicine_name']}  ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['dosage']}         ${dosage}
    Should Be Equal As Strings  ${resp.json()['notes']}                                  ${notes}

   
    ${MR_Description_name}=  Format String   ${MR_Description_name}      ${firstname0} ${lastname0}
    ${PRE_Description_name}=  Format String   ${PRE_Description_name}    ${firstname0} ${lastname0}
    ${CLINI_Description_name}=  Format String   ${CLINI_Description_name}  ${firstname0} ${lastname0}

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[2]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${CLINI_Description_name}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${PRE_Description_name}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${PRE_Description_name}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[3]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[3]['Description']}       ${MR_Description_name}
    Should Be Equal As Strings  ${resp.json()[3]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[3]['DateTime']}          ${C_date} ${ctime}

    

JD-TC-Getauditlog-10
    [Documentation]   Get auditlog for appointment(walkin).
    ...               (Here 1st create a MR for an appointment, then create another prescription and then get auditlog ) 

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${cusername}   ${resp.json()['userName']}
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
 
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME18}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${loc_id1}

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME18}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${sTime1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${MR_Description_name}=  Format String     ${MR_Description_name}      ${cusername}
    ${PRE_Description_name}=  Format String    ${PRE_Description_name}     ${cusername}
    ${CLINI_Description_name}=  Format String   ${CLINI_Description_name}  ${cusername}
    ${PRE_UpdateDescription}=  Format String   ${PRE_UpdateDescription}  ${mrid}
    
    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[2]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${CLINI_Description_name}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${PRE_Description_name}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${MR_Description_name}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}
    
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence
    ${notes}=          FakerLibrary.sentence

    ${pre_list1}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR prescription by mr id   ${mr_id}  ${notes}  ${pre_list1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['frequency']}      ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['duration']}       ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['instructions']}   ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['medicine_name']}  ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['dosage']}         ${dosage}
    Should Be Equal As Strings  ${resp.json()['notes']}                                  ${notes}
   
    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[2]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${CLINI_Description_name}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${PRE_Description_name}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${PRE_Description_name}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[3]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[3]['Description']}       ${MR_Description_name}
    Should Be Equal As Strings  ${resp.json()[3]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[3]['DateTime']}          ${C_date} ${ctime}


JD-TC-Getauditlog-11
    [Documentation]   Get auditlog for appointment(walkin).
    ...              (Here created a MR, then create another prescription  and then update that prescription.)
    
    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${cusername}   ${resp.json()['userName']}
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot3}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME14}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot3}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot3}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot3}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${loc_id1}

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME14}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${sTime1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}

    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence
    ${notes}=          FakerLibrary.sentence

    ${pre_list1}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR prescription by mr id   ${mr_id}  ${notes}  ${pre_list1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['frequency']}      ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['duration']}       ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['instructions']}   ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['medicine_name']}  ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['dosage']}         ${dosage}
    Should Be Equal As Strings  ${resp.json()['notes']}                                  ${notes}

   
    ${med_name1}=      FakerLibrary.name
    ${frequency1}=     FakerLibrary.word
    ${duration1}=      FakerLibrary.sentence
    ${instrn1}=        FakerLibrary.sentence
    ${dosage1}=        FakerLibrary.sentence
    ${notes1}=          FakerLibrary.sentence

    ${pre_list11}=  Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  duration=${duration1}  instructions=${instrn1}  dosage=${dosage1}
    
    ${resp}=  Create MR prescription by mr id   ${mr_id}  ${notes1}  ${pre_list11}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['frequency']}      ${frequency1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['duration']}       ${duration1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['instructions']}   ${instrn1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['medicine_name']}  ${med_name1}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['dosage']}         ${dosage1}
    Should Be Equal As Strings  ${resp.json()['notes']}                                  ${notes1}


    ${MR_Description_name}=  Format String     ${MR_Description_name}      ${cusername}
    ${PRE_Description_name}=  Format String    ${PRE_Description_name}     ${cusername}
    ${CLINI_Description_name}=  Format String   ${CLINI_Description_name}  ${cusername}
    ${PRE_UpdateDescription}=  Format String   ${PRE_UpdateDescription}    ${mrid}
    
    sleep  2s
    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[2]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${CLINI_Description_name}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${PRE_Description_name}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${PRE_Description_name}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[3]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[3]['Description']}       ${PRE_Description_name}
    Should Be Equal As Strings  ${resp.json()[3]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[3]['DateTime']}          ${C_date} ${ctime}
  
    Should Be Equal As Strings  ${resp.json()[4]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[4]['Description']}       ${MR_Description_name}
    Should Be Equal As Strings  ${resp.json()[4]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[4]['DateTime']}          ${C_date} ${ctime}


JD-TC-Getauditlog-12
    [Documentation]   Get auditlog for appointment(walkin).
    ...              (Here created a MR without passing prescription and clinical notes and then create a clinical notes.)
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME11}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    # Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${loc_id1}

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR  ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}   ${CUR_DAY}  ${status[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME11}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${sTime1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}

    ${MR_Description}=  Format String   ${MR_Description}          ${cid}
    ${CLINI_Description}=  Format String   ${CLINI_Description}    ${cid}
    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${MR_Description}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    ${symptoms1}=      FakerLibrary.name
    ${allergies1}=     FakerLibrary.word
    ${diagnosis1}=     FakerLibrary.sentence
    ${complaints1}=    FakerLibrary.sentence
    ${misc_notes1}=    FakerLibrary.word
    ${observations1}=  FakerLibrary.sentence
    ${vaccinationHistory1}=  FakerLibrary.sentence

    ${type}=     FakerLibrary.word
    ${clinicalNote}=     FakerLibrary.word

    ${clinicalNote1}=        FakerLibrary.sentence
    ${type1}=        FakerLibrary.sentence

    ${resp}=  Create MR clinical notes by mr id   ${mr_id}   $${type}  ${clinicalNote}    ${attachment1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type1}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote1}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}              ${caption}
   
    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[2]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${CLINI_Description}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${MR_Description}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    

JD-TC-Getauditlog-13
 
    [Documentation]   Get auditlog with uplord and then share mr prescription then delete prescription 

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${cusername}   ${resp.json()['userName']}
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=   db.get_time_by_timezone  ${tz}
    ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[0]}   ${CUR_DAY}  ${status[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME13}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()['prescriptions']}                    []
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['caption']}   prescription
    # Should Contain  ${resp.json()['prescriptionsList'][0]['prefix']}  prescription
    # Set Suite Variable  ${imgName}  ${resp.json()['prescriptionsList'][0]['keyName']}  
    # Set Suite Variable  ${CUR_DAY}  ${resp.json()['prescriptionsList'][0]['date']}


    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription   ${mr_id}   ${msg}  ${EMPTY}   ${boolean[0]}  ${boolean[1]}  ${boolean[0]}   ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${MR_Description_name}=  Format String   ${MR_Description_name}      ${cusername}
    ${PRE_ImageDescription}=  Format String   ${PRE_ImageDescription}    ${mr_id}
    ${PRE_ShareDescription}=  Format String   ${PRE_ShareDescription}    ${mr_id}    ${cusername}
    ${PRE_RemoveDescription}=  Format String   ${PRE_RemoveDescription}  ${mr_id}
    
    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[8]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${PRE_ShareDescription}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[6]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${PRE_ImageDescription}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${MR_Description_name}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}


    ${resp}=  DeletePrescriptionImg  ${mrid}  ${imgName}  ${cookie}
    # sleep  02s
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[11]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${PRE_RemoveDescription}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[8]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${PRE_ShareDescription}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}
   
    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[6]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${PRE_ImageDescription}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}
   
    Should Be Equal As Strings  ${resp.json()[3]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[3]['Description']}       ${MR_Description_name}
    Should Be Equal As Strings  ${resp.json()[3]['User']}              ${userName}
    Should Be Equal As Strings  ${resp.json()[3]['DateTime']}          ${C_date} ${ctime}

JD-TC-Getauditlog-14
 
    [Documentation]   Get auditlog with uplord clinical note and prescription  and then share prescription

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${cusername}   ${resp.json()['userName']}
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME16}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=   db.get_time_by_timezone  ${tz}
    ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[0]}   ${CUR_DAY}  ${status[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME16}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()['prescriptions']}                    []
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadClinicalnotesImage    ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['caption']}   clinicalnotes
    Should Contain  ${resp.json()[0]['prefix']}  clinicalNotes
    Set Suite Variable  ${imgName}  ${resp.json()[0]['keyName']}  
    # Set Suite Variable  ${CUR_DAY}  ${resp.json()[0]['date']}

    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['caption']}   prescription
    # Should Contain  ${resp.json()['prescriptionsList'][0]['prefix']}  prescription
    # Set Suite Variable  ${imgName}  ${resp.json()['prescriptionsList'][0]['keyName']}  
    # Set Suite Variable  ${CUR_DAY}  ${resp.json()['prescriptionsList'][0]['date']}

    ${resp}=   uploadDigitalSign   ${id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription   ${mr_id}   ${msg}  ${EMPTY}   ${boolean[0]}  ${boolean[1]}  ${boolean[0]}   ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${MR_Description_name}=  Format String   ${MR_Description_name}      ${cusername}
    ${CLINI_ImageDescription}=  Format String   ${CLINI_ImageDescription}    ${mr_id}
    ${PRE_ImageDescription}=  Format String   ${PRE_ImageDescription}    ${mr_id}
    ${PRE_ShareDescription}=  Format String    ${PRE_ShareDescription}    ${mr_id}    ${cusername}
    
    ${ctime}=   db.get_time_by_timezone  ${tz}
    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[8]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${PRE_ShareDescription}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName1}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[6]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${PRE_ImageDescription}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName1}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${MR_Description_name}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName1}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}

    # Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[7]}
    # Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${CLINI_ImageDescription}
    # Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName1}
    # Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    # Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[6]}
    # Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${PRE_ImageDescription}
    # Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName1}
    # Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}

   
JD-TC-Getauditlog-15
 
    [Documentation]   Get auditlog with share prescription

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${cusername}   ${resp.json()['userName']}
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME15}   firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=   db.get_time_by_timezone  ${tz}
    ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[0]}   ${CUR_DAY}  ${status[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME15}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()['prescriptions']}                    []
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}

    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence
    ${notes}=          FakerLibrary.sentence

    ${pre_list1}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR prescription by mr id   ${mr_id}  ${notes}  ${pre_list1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['frequency']}      ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['duration']}       ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['instructions']}   ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['medicine_name']}  ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptionsList'][0]['dosage']}         ${dosage}
    Should Be Equal As Strings  ${resp.json()['notes']}                                  ${notes}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription   ${mr_id}   ${msg}  ${html}   ${boolean[0]}  ${boolean[1]}  ${boolean[0]}   ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${MR_Description_name}=  Format String   ${MR_Description_name}     ${cusername}
    ${PRE_Description_name}=  Format String   ${PRE_Description_name}    ${cusername}
    # ${CLINI_Description_name}=  Format String   ${CLINI_Description_name}  ${cusername}
    ${PRE_ShareDescription}=  Format String   ${PRE_ShareDescription}    ${mr_id}    ${cusername}
   
    ${ctime}=   db.get_time_by_timezone  ${tz}
    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['Action']}            ${mraction[8]}
    Should Be Equal As Strings  ${resp.json()[0]['Description']}       ${PRE_ShareDescription}
    Should Be Equal As Strings  ${resp.json()[0]['User']}              ${userName1}
    Should Be Equal As Strings  ${resp.json()[0]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[1]['Action']}            ${mraction[1]}
    Should Be Equal As Strings  ${resp.json()[1]['Description']}       ${PRE_Description_name}
    Should Be Equal As Strings  ${resp.json()[1]['User']}              ${userName1}
    Should Be Equal As Strings  ${resp.json()[1]['DateTime']}          ${C_date} ${ctime}

    Should Be Equal As Strings  ${resp.json()[2]['Action']}            ${mraction[0]}
    Should Be Equal As Strings  ${resp.json()[2]['Description']}       ${MR_Description_name}
    Should Be Equal As Strings  ${resp.json()[2]['User']}              ${userName1}
    Should Be Equal As Strings  ${resp.json()[2]['DateTime']}          ${C_date} ${ctime}

   
JD-TC-Getauditlog-UH1
 
    [Documentation]   Get auditlog by using another provider's mrid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MEDICAL_RECORD_NOT_FOUND}"


JD-TC-Getauditlog-UH2
 
    [Documentation]   Get auditlog with invalid mrid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get MR Auditlogs by MR Id    000
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MEDICAL_RECORD_NOT_FOUND}"


JD-TC-Getauditlog-UH3
 
    [Documentation]   Get auditlog without login

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-Getauditlog-UH4
 
    [Documentation]   Get auditlog with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"




























*** Comments ***
JD-TC-Getauditlog-4
 
    [Documentation]   Get auditlog with mr prescription create to another waitlisted customer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[0]}   ${CUR_DAY}  ${status[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${med_name1}=      FakerLibrary.name
    ${frequency1}=     FakerLibrary.word
    ${duration1}=      FakerLibrary.sentence
    ${instrn1}=        FakerLibrary.sentence
    ${resp}=  Create MR prescription by mr id   ${mr_id}   ${med_name1}  ${frequency1}  ${duration1}  ${instrn1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['duration']}              ${duration1}
    Should Be Equal As Strings  ${resp.json()[0]['frequency']}             ${frequency1}
    Should Be Equal As Strings  ${resp.json()[0]['instructions']}          ${instrn1}
    Should Be Equal As Strings  ${resp.json()[0]['medicine_name']}         ${med_name1}
   
    ${resp}=  Get MR Auditlogs by MR Id   ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

